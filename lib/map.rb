class Map
  attr_accessor :surface, :minzoom, :maxzoom, :basezoom, :tilesize
  def self.resize(filepath, output_file, scale)
    ratio = scale
    dims = Dimensions.dimensions(filepath)
    _width = (dims[0] * ratio).to_i
    _height = (dims[1] * ratio).to_i
    puts "#{ratio} #{dims[0]}x#{dims[1]} -> #{_width}x#{_height} #{output_file}"
    if ratio == 1
      cmd_exec("cp #{filepath} #{output_file}")
    else
      cmd_exec("convert -geometry #{_width}x#{_height} #{filepath} #{output_file}")
    end
    return _width, _height 
  end

  def self.cmd_exec(cmd, flag_v = true)
    puts cmd if flag_v
    msg = `#{cmd}`
    raise msg unless msg.empty?
    #return system(cmd)
  end


  def self.make_tile(file, tile_dir, tmp_dir, zoom, basezoom, tilesize)
    basename = File.basename(file, ".*")
    output_dir = File.join(tile_dir, zoom.to_s)
    unless Dir.exist?(output_dir)
      Dir.mkdir(output_dir)
    end
    working_dir = File.join(tmp_dir, zoom.to_s)
    unless Dir.exist?(working_dir)
      Dir.mkdir(working_dir)
    end
    png_file_path = File.join(tmp_dir,"#{basename}-#{zoom}.png")
    scale = 2 ** (zoom - basezoom)
    width, height = resize(file, png_file_path, scale)
    tilebase = File.join(working_dir, "#{basename}_%d.png")
    tiles_per_column = (width.to_i/tilesize) + 1
    tiles_per_row = (height.to_i/tilesize) + 1
    bg_width = tiles_per_column * tilesize
    bg_height = tiles_per_row * tilesize
    bg_file_path = File.join(tmp_dir,"bg-#{zoom}.png")
    cmd_exec("convert -size #{bg_width.to_s}x#{bg_height.to_s} xc:none #{bg_file_path}")
    new_file_path = File.join(tmp_dir, "new-#{zoom}.png")
    cmd_exec("convert #{bg_file_path} #{png_file_path} -gravity northwest -geometry +#{0}+#{0} -composite #{new_file_path}")

    cmd_exec("convert -crop #{tilesize}x#{tilesize} +repage #{new_file_path} #{tilebase}")
    total_tiles = Dir[File.join(working_dir, "#{basename}_*.png")].length
    n = 0
    row = 0
    column = 0
    (n...total_tiles).each do |i|
      filename = File.join(working_dir, "#{basename}_#{i}.png") # current filename
      target = File.join(tile_dir, zoom.to_s, "#{column}_#{row}.png") # new filename
      cmd_exec("cp -f #{filename} #{target}", false) # rename
      column = column + 1
      if column >= tiles_per_column
        column = 0
        row = row + 1
      end
    end
  end

  def initialize(surface)
    @surface = surface
    @tilesize = 256
    @minzoom = 8
    @maxzoom = 14
    @basezoom = 13
  end

  def generate_tiles(opts = {})
    generate_bg_tiles(opts)
  end
  
  def generate_bg_tiles(opts = {})
    image = surface.images[0]
    path = image.path
    public_dir = File.join(Dir.pwd(),'public')
    file = File.join(public_dir, File.dirname(path),File.basename(path,"?*"))
    tile_dir = File.join(public_dir, "system/maps/#{surface.id}/layers/0/tiles")
    unless Dir.exist?(tile_dir)
      FileUtils.mkdir_p(tile_dir)
    end
    tmp_dir = File.join(Dir.pwd,"tmp/maps/#{surface.id}/layers/0")
    unless Dir.exist?(tmp_dir)
      FileUtils.mkdir_p(tmp_dir)
    end

    (minzoom..maxzoom).each do |zoom|
      puts "zoom: #{zoom}"
      self.class.make_tile(file, tile_dir, tmp_dir, zoom, basezoom, tilesize)
    end
  end

end
