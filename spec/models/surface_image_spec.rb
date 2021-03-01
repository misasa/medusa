require 'spec_helper'
include ActionDispatch::TestProcess

describe SurfaceImage do
  let(:surface) { FactoryBot.create(:surface) }
  let(:obj) { FactoryBot.create(:surface_image, :surface_id => surface.id, :image_id => image.id)}

  describe "with real file" do
    let(:image) { FactoryBot.create(:attachment_file, affine_matrix: [9.5e+01,-1.8e+01,-2.0e+02,1.8e+01,9.4e+01,-3.3e+01,0,0,1]) }
    describe "make_warped_image" do
      subject {obj.make_warped_image}
      before do
        allow(image).to receive(:local_path).and_return(File.join(fixture_path, "/files/test_image.jpg"))
        allow(obj).to receive(:image).and_return(image)
      end
      it { expect{subject}.not_to raise_error }
    end
  end

  let(:image) { FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
  
  describe "make_tiles_cmd", :current => true do
    let(:surface) { FactoryBot.create(:surface) }
    let(:obj) { FactoryBot.create(:surface_image, :surface_id => surface.id, :image_id => image.id)}
    let(:options){ {} }
    subject {obj.make_tiles_cmd(options)}
    before do
      allow(File).to receive(:exist?).with(image.local_path).and_return(true)
    end
    context "without surface_layer" do
      before do
        allow(obj).to receive(:original_zoom_level).and_return(12)
      end
      it { expect(subject.command).to match(/\-z 12/) }
    end
    context "with surface_layer with max_zoom_level" do
      let(:layer) { FactoryBot.create(:surface_layer, :max_zoom_level => 11) }
      before do
        obj.surface_layer = layer
        obj.save
      end
      it { expect(subject.command).to match(/\-z 11/) }
    end

    context "with surface_layer without max_zoom_level" do
      let(:layer) { FactoryBot.create(:surface_layer) }
      before do
        obj.surface_layer = layer
        allow(layer).to receive(:original_zoom_level).and_return(10)
        obj.save
      end
      it { expect(subject.command).to match(/\-z 10/) }
    end
  end

  describe "merge_tiles_cmd", :current => true do
    let(:surface) { FactoryBot.create(:surface) }
    let(:obj) { FactoryBot.create(:surface_image, :surface_id => surface.id, :image_id => image.id)}
    let(:options){ {} }
    subject {obj.merge_tiles_cmd(options)}
    context "without surface_layer" do
      it { expect(subject).to be_nil }
    end
    context "with surface_layer with max_zoom_level" do
      let(:layer) { FactoryBot.create(:surface_layer, :max_zoom_level => 11) }
      before do
        obj.surface_layer = layer
        obj.save
      end
      it { expect(subject.command).to match(/\-z 11/) }
    end

    context "with surface_layer without max_zoom_level" do
      let(:layer) { FactoryBot.create(:surface_layer) }
      before do
        obj.surface_layer = layer
        allow(layer).to receive(:original_zoom_level).and_return(10)
        obj.save
      end
      it { expect(subject.command).to match(/\-z 10/) }
    end
  end

  describe "scope" do
    describe "wall" do
      let(:image_1){ FactoryBot.create(:attachment_file) }
      let(:wall_image){ FactoryBot.create(:surface_image, :wall => true, :surface_id => surface.id, :image_id => image_1.id) }
      let(:image_2){ FactoryBot.create(:attachment_file) }
      let(:overlay_image){ FactoryBot.create(:surface_image, :surface_id => surface.id, :image_id => image_2.id) }
      subject { SurfaceImage.wall }
      it { expect(subject).to include(wall_image) }
      it { expect(subject).not_to include(overlay_image) }
    end

    describe "base" do
      let(:image_1){ FactoryBot.create(:attachment_file) }
      let(:wall_image){ FactoryBot.create(:surface_image, :wall => true, :surface_id => surface.id, :image_id => image_1.id) }
      let(:image_2){ FactoryBot.create(:attachment_file) }
      let(:overlay_image){ FactoryBot.create(:surface_image, :surface_id => surface.id, :image_id => image_2.id) }
      subject { SurfaceImage.base }
      it { expect(subject).to include(wall_image) }
      it { expect(subject).not_to include(overlay_image) }
    end

    describe "overlay" do
      let(:image_1){ FactoryBot.create(:attachment_file) }
      let(:wall_image){ FactoryBot.create(:surface_image, :wall => true, :surface_id => surface.id, :image_id => image_1.id) }
      let(:image_2){ FactoryBot.create(:attachment_file) }
      let(:overlay_image){ FactoryBot.create(:surface_image, :surface_id => surface.id, :image_id => image_2.id) }
      subject { SurfaceImage.overlay }
      it { expect(subject).not_to include(wall_image) }
      it { expect(subject).to include(overlay_image) }
    end

    describe "calibrated" do
      subject { SurfaceImage.calibrated }
      let(:image_1){ FactoryBot.create(:attachment_file) }
      let(:calibrated_image){ FactoryBot.create(:surface_image, :wall => true, :surface_id => surface.id, :image_id => image_1.id) }
      let(:image_2){ FactoryBot.create(:attachment_file, :affine_matrix => nil) }
      let(:uncalibrated_image){ FactoryBot.create(:surface_image, :surface_id => surface.id, :image_id => image_2.id) }
      let(:image_3){ FactoryBot.create(:attachment_file, :affine_matrix => []) }
      let(:uncalibrated_image_2){ FactoryBot.create(:surface_image, :surface_id => surface.id, :image_id => image_3.id) }
      it { expect(subject).to include(calibrated_image) }
      it { expect(subject).not_to include(uncalibrated_image) }
      it { expect(subject).not_to include(uncalibrated_image_2) }
    end

  end


  describe "#width" do
    subject { obj.width }
    context "with left and right attributes" do
      let(:obj) {FactoryBot.create(:surface_image, :surface_id => surface.id, left: left, right: right)}
      let(:left) {-3808.472}
      let(:right) {3851.032}
      before do
        image_mock = double('Image')
        image_mock.should_not_receive(:width_in_um)
        allow(obj).to receive(:image).and_return(image_mock)
      end
      it { expect(subject).to eq(right - left)}
    end
    context "without left and right attributes" do
      before do
        image_mock = double('Image')
        image_mock.should_receive(:width_in_um).and_return(1000)
        allow(obj).to receive(:image).and_return(image_mock)
      end
      it { expect(subject).to eq(1000)}
    end

  end

  describe "#height" do
    subject { obj.height }
    context "with upper and bottom attributes" do
      let(:obj) {FactoryBot.create(:surface_image, :surface_id => surface.id, upper: upper, bottom: bottom)}
      let(:upper) {3787.006}
      let(:bottom) {-4007.006}

      before do
        image_mock = double('Image')
        image_mock.should_not_receive(:height_in_um)
        allow(obj).to receive(:image).and_return(image_mock)
      end
      it { expect(subject).to eq(upper - bottom)}
    end
    context "without upper and bottom attributes" do
      before do
        image_mock = double('Image')
        image_mock.should_receive(:height_in_um).and_return(1000)
        allow(obj).to receive(:image).and_return(image_mock)
      end
      it { expect(subject).to eq(1000)}
    end

  end


  describe "#bounds" do
    subject { obj.bounds }
    let(:obj) { FactoryBot.create(:surface_image, :surface_id => surface.id)}
    let(:left) {-3808.472}
    let(:upper) {3787.006}
    let(:right) {3851.032}
    let(:bottom) {-4007.006}
    context "with attributes" do
      let(:obj) {FactoryBot.create(:surface_image, :surface_id => surface.id, left: left, upper: upper, right: right, bottom: bottom)}
      before do
        image_mock = double('Image')
        image_mock.should_not_receive(:bounds)
        allow(obj).to receive(:image).and_return(image_mock)
      end      
      it { expect(subject).to eq([left,upper,right,bottom])}
    end
    context "without attributes" do
      before do
        image_mock = double('Image')
        image_mock.should_receive(:bounds).and_return([left,upper,right,bottom])
        allow(obj).to receive(:image).and_return(image_mock)
      end
      it { expect(subject).to eq([left,upper,right,bottom])}
    end
  end

  describe "#original_zoom_level" do
    subject { obj.original_zoom_level }
    it {expect(subject).to eq(5)}
    context "with large image" do
      let(:image) { FactoryBot.create(:attachment_file, :original_geometry => "40960x34150", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
      it { expect(subject).to eq(8)  }
    end

    context "with small image" do
      let(:image) { FactoryBot.create(:attachment_file, :original_geometry => "410x342", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
      it { expect(subject).to eq(1)  }
    end


    context "without image" do
      before do
        obj.image = nil
      end
      it { expect(subject).to be_nil  }
    end
    
  end


  describe "#resolution" do
    subject { obj.resolution }
    it { expect(subject).to be_within(0.01).of(0.42)}
  end

  
  describe "#corners_on_map" do
    subject { obj.corners_on_map }
    it { expect{ subject }.not_to raise_error }
  end
  
  describe "#corners_on_map=" do
    subject { obj.corners_on_map = corners_on_map }
    before do
      image_mock = double('Image')
      image_mock.should_receive(:corners_on_world=)
      image_mock.should_receive(:save)
      allow(obj).to receive(:image).and_return(image_mock)
    end
    context "with string" do
      let(:corners_on_map){ "176.33,46.50:179.07,46.60:178.97,48.67:176.23,48.58"  }
      it { expect(subject).to eql(corners_on_map)  }
    end
    context "with array" do
      let(:corners_on_map){ [[176.33,46.50],[179.07,46.60],[178.97,48.67],[176.23,48.58]] }
      it { expect(subject).to eql([[176.33,46.50],[179.07,46.60],[178.97,48.67],[176.23,48.58]])  }
    end
  end

  describe "#corners_on_world=" do
    subject { obj.corners_on_world = corners_on_world }
    before do
      image_mock = double('Image')
      image_mock.should_receive(:corners_on_world=)
      image_mock.should_receive(:save)
      allow(obj).to receive(:image).and_return(image_mock)
    end
    context "with string" do
      let(:corners_on_world){ "176.33,46.50:179.07,46.60:178.97,48.67:176.23,48.58"  }
      it { expect(subject).to eql(corners_on_world)  }
    end
    context "with array" do
      let(:corners_on_world){ [[176.33,46.50],[179.07,46.60],[178.97,48.67],[176.23,48.58]] }
      it { expect(subject).to eql([[176.33,46.50],[179.07,46.60],[178.97,48.67],[176.23,48.58]])  }
    end
  end


  describe "#corners_on_world" do
    subject {obj.corners_on_world}
    context "with calibrated image" do
      it { expect(subject).to eql(obj.image.corners_on_world)}
    end
    context "with uncalibrated image" do
      let(:image) { FactoryBot.create(:attachment_file, affine_matrix: nil) }
      let(:corners) {[[0,0],[760,0],[760,-700],[0,-700]]}
      before do
        allow(surface).to receive(:initial_corners_for).with(image).and_return(corners)
        allow(obj).to receive(:surface).and_return(surface)
        allow(obj).to receive(:image).and_return(image)
      end
      it { expect(subject).to eql(corners)}
    end
  end

  context "with spot" do

  let(:spot) { FactoryBot.create(:spot, :attachment_file_id => image.id) }

  before do
  	surface
  	image
  	spot
  	obj
  end

  describe "spots" do
  	it { expect(obj.spots).to include(spot)}
    context "shares same surface's spots" do
	    let(:image_1) { FactoryBot.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:image_2) { FactoryBot.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:spot_1) { FactoryBot.create(:spot, :attachment_file_id => image_1.id) }
	    let(:spot_2) { FactoryBot.create(:spot, :attachment_file_id => image_2.id) }

	    before do
	      surface.images << image_1
        surface.images << image_2
      end
      pending("...") do   
        it { expect(obj.spots.count).to eql(2)}
      end
    end
  end

  describe "to_region" do
  	context "shares same surface's spots" do
	    let(:image_1) { FactoryBot.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:image_2) { FactoryBot.create(:attachment_file, :original_geometry => "1280x1024", :affine_matrix_in_string => "[7.646e+00,-9.538e-01,3.054e+02;8.346e-01,7.890e+00,-2.109e+03;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:spot_1) { FactoryBot.create(:spot, :attachment_file_id => image_1.id) }
	    let(:spot_2) { FactoryBot.create(:spot, :attachment_file_id => image_2.id) }
	  	before do
	      surface.images << image_1
	      surface.images << image_2
	      spot_1
	      spot_2
	    end
	  	it { expect(obj.to_region).to match(/<polyline/)}
    end  	
  end

  describe "to_svg" do
  	subject {obj.to_svg}
 # 	it { expect(subject).to match(/<circle/)}
  	context "shares same surface's spots" do
 	    let(:image) { FactoryBot.create(:attachment_file, :original_geometry => "1198x665", :affine_matrix_in_string => "[1.944e+01,2.527e+02,-1.727e+02;-2.546e+02,1.804e+01,1.330e+03;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:image_1) { FactoryBot.create(:attachment_file, :original_geometry => "1280x1024", :affine_matrix_in_string => "[1.278e+01,7.878e-01,4.336e+03;-1.457e+00,1.198e+01,-5.911e+02;0.000e+00,0.000e+00,1.000e+00]") }
#	    let(:image_2) { FactoryBot.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:spot_1) { FactoryBot.create(:spot, :attachment_file_id => image_1.id) }
#	    let(:spot_2) { FactoryBot.create(:spot, :attachment_file_id => image_2.id) }
	  	before do
	      surface.images << image_1
#	      surface.images << image_2
	      spot_1
#	      spot_2
	      #puts subject
	    end
	  	it { expect(obj.to_svg).to match(/<circle/)}
    end
  end

  end
end
