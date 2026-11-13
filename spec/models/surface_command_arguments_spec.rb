require 'spec_helper'
require 'json'
require 'tmpdir'
require 'rbconfig'
require 'climate_control'

RSpec.describe 'Surface image command arguments' do
  let(:filename) { 'sample.png' }
  let(:input_path) { File.join(@workspace, filename) }
  let(:png_path) { File.join(@workspace, "converted #{filename}") }
  let(:warped_path) { File.join(@workspace, "warped #{filename}") }
  let(:output_dir) { File.join(@workspace, filename, 'tiles') }
  let(:corners) { [[0, 2], [2, 2], [2, 0], [0, 0]] }
  let(:corners_arg) { '[[0.00,2.00],[2.00,2.00],[2.00,0.00],[0.00,0.00]]' }
  let(:surface) { double('surface', center: [1, 1], length: 10) }
  let(:image) { AttachmentFile.new }
  let(:surface_image) { SurfaceImage.new }
  let(:layer) { SurfaceLayer.new }

  # Exercise Terrapin and the shell; replace only the external image programs.
  # The recorder captures what the child process actually receives as ARGV.
  around do |example|
    Dir.mktmpdir('medusa-command-spec-') do |workspace|
      @workspace = workspace
      @capture_path = File.join(workspace, 'argv.json')
      bin_dir = File.join(workspace, 'bin')
      Dir.mkdir(bin_dir)
      recorder = <<~RUBY
        #!#{RbConfig.ruby}
        require 'json'
        File.write(ENV.fetch('MEDUSA_ARGV_CAPTURE'), JSON.generate(ARGV))
        exit Integer(ENV.fetch('MEDUSA_COMMAND_EXIT', '0'))
      RUBY
      %w[make_tiles image_in_image].each do |command|
        path = File.join(bin_dir, command)
        File.write(path, recorder)
        File.chmod(0755, path)
      end
      ClimateControl.modify('PATH' => "#{bin_dir}:#{ENV['PATH']}",
                            'MEDUSA_ARGV_CAPTURE' => @capture_path,
                            'MEDUSA_COMMAND_EXIT' => '0') do
        example.run
      end
    end
  end

  before do
    File.write(input_path, 'input image')
    File.write(png_path, 'converted image')
    allow(image).to receive_messages(local_path: input_path, png_path: png_path,
                                    fits_file?: false, image?: true,
                                    bounds: [0, 2, 2, 0], pixels_per_um: 1,
                                    corners_on_world: corners)
    allow(surface_image).to receive_messages(surface: surface, image: image,
                                            surface_layer: layer, wall: false,
                                            image_path: input_path, warped_image_path: warped_path,
                                            tile_dir: output_dir, original_zoom_level: 10,
                                            corners_on_world_str: corners_arg)
    allow(layer).to receive_messages(surface: surface, surface_images: [surface_image],
                                    tile_dir: output_dir, max_zoom_level: 12,
                                    original_zoom_level: 11)
    [image, surface_image, layer].each do |model|
      allow(model).to receive(:logger).and_return(Logger.new(nil))
    end
    # Keep rotated images and temporary files inside the per-example directory.
    temp_dir = File.join(@workspace, "temporary-#{filename}")
    Dir.mkdir(temp_dir)
    allow(Tempfile).to receive(:new).and_wrap_original do |original, basename|
      original.call(basename, temp_dir)
    end
  end

  def captured_argv
    JSON.parse(File.read(@capture_path))
  end

  def tile_argv(path = input_path, zoom = '12')
    [path, corners_arg, '10.00', '[1.00,1.00]', '-o', output_dir, '-z', zoom]
  end

  ['sample.png', 'sample scan.png', "sample's scan.png",
   'sample & (scan).png', '試料 画像.png'].each do |name|
    context "with #{name.inspect}" do
      let(:filename) { name }

      it 'preserves input and temporary output paths when rotating' do
        output = image.rotate
        expect(captured_argv).to eq([input_path, output, '[[0,0],[2,0],[2,2],[0,2]]',
                                    '-p', 'nearest', '-o', output])
        expect(File.file?(output)).to eq(true)
      end

      it 'preserves paths when making image tiles' do
        surface_image.make_tiles_cmd.run
        expect(captured_argv).to eq(tile_argv + ['-t'])
      end

      it 'preserves paths when making layer tiles' do
        layer.make_tiles_cmd.run
        expect(captured_argv).to eq(tile_argv + ['-t', '--multi', '4'])
      end

      it 'preserves paths when merging warped image tiles' do
        surface_image.merge_tiles_cmd.run
        expect(captured_argv).to eq([warped_path, '[0.00,2.00,2.00,0.00]',
                                    '10.00', '[1.00,1.00]', '-o', output_dir,
                                    '-z', '12', '-t', '--compose'])
      end
    end
  end

  context 'with a FITS image' do
    before { allow(image).to receive(:fits_file?).and_return(true) }

    it 'rotates the converted PNG' do
      output = image.rotate
      expect(captured_argv).to eq([png_path, output, '[[0,0],[2,0],[2,2],[0,2]]',
                                  '-p', 'nearest', '-o', output])
    end

    it 'makes image tiles from the converted PNG' do
      surface_image.make_tiles_cmd.run
      expect(captured_argv).to eq(tile_argv(png_path) + ['-t'])
    end

    it 'makes layer tiles from the converted PNG' do
      layer.make_tiles_cmd.run
      expect(captured_argv).to eq(tile_argv(png_path) + ['-t', '--multi', '4'])
    end
  end

  it 'preserves image tile options, including multi-token transparent_color' do
    surface_image.make_tiles_cmd(maxzoom: 8, transparent: false,
                                 transparent_color: '-c 0 0 0').run
    expect(captured_argv).to eq(tile_argv(input_path, '8') + ['-c', '0', '0', '0'])
  end

  it 'preserves layer options and explicit multi' do
    layer.make_tiles_cmd(maxzoom: 8, transparent: false,
                         transparent_color: '-c 0 0 0', multi: 2).run
    expect(captured_argv).to eq(tile_argv(input_path, '8') + ['-c', '0', '0', '0', '--multi', '2'])
  end

  it 'omits the multiprocessing option when disabled' do
    layer.make_tiles_cmd(multi: false).run
    expect(captured_argv).to eq(tile_argv + ['-t'])
  end

  it 'preserves merge options and compose' do
    surface_image.merge_tiles_cmd(maxzoom: 8, transparent: false,
                                  transparent_color: '-c 0 0 0').run
    expect(captured_argv).to eq([warped_path, '[0.00,2.00,2.00,0.00]',
                                '10.00', '[1.00,1.00]', '-o', output_dir,
                                '-z', '8', '-c', '0', '0', '0', '--compose'])
  end

  it 'keeps the reversed layer image order and skips wall and missing images' do
    second_path = File.join(@workspace, 'second image.png')
    File.write(second_path, 'second image')
    second = double('second surface image', wall: false, image: image,
                    image_path: second_path, corners_on_world_str: corners_arg)
    wall = double('wall surface image', wall: true)
    missing = double('missing surface image', wall: false, image: image,
                     image_path: File.join(@workspace, 'missing.png'))
    allow(layer).to receive(:surface_images).and_return([surface_image, wall, missing, second])
    layer.make_tiles_cmd.run
    expect(captured_argv).to eq([second_path, corners_arg] + tile_argv + ['-t', '--multi', '4'])
  end

  it 'returns no image command when the input file is missing' do
    File.delete(input_path)
    expect(surface_image.make_tiles_cmd).to be_nil
  end

  it 'returns no layer command when no usable images remain' do
    File.delete(input_path)
    expect(layer.make_tiles_cmd).to be_nil
  end

  it 'returns no merge command without a layer' do
    allow(surface_image).to receive(:surface_layer).and_return(nil)
    expect(surface_image.merge_tiles_cmd).to be_nil
  end

  it 'uses the image zoom when there is no layer' do
    allow(surface_image).to receive(:surface_layer).and_return(nil)
    surface_image.make_tiles_cmd.run
    expect(captured_argv).to eq(tile_argv(input_path, '10') + ['-t'])
  end

  it 'falls back to the original layer zoom' do
    allow(layer).to receive(:max_zoom_level).and_return(nil)
    layer.make_tiles_cmd.run
    expect(captured_argv).to eq(tile_argv(input_path, '11') + ['-t', '--multi', '4'])
  end

  it 'propagates external command failures from rotate' do
    ClimateControl.modify('MEDUSA_COMMAND_EXIT' => '1') do
      expect { image.rotate }.to raise_error(Terrapin::ExitStatusError)
    end
  end
end
