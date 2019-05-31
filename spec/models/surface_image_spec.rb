require 'spec_helper'

describe SurfaceImage do
  let(:surface) { FactoryGirl.create(:surface) }
  let(:image) { FactoryGirl.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }

  let(:obj) { FactoryGirl.create(:surface_image, :surface_id => surface.id, :image_id => image.id)}
  let(:spot) { FactoryGirl.create(:spot, :attachment_file_id => image.id) }

  before do
  	surface
  	image
  	spot
  	obj
  end

  describe "tiles_ij", :current => true do
    let(:zoom){ 5 }
    before do
      mock_surface = double('mock_surface')
      mock_image = double('mock_image')
      allow(mock_surface).to receive(:center).and_return([-20.28,-110.0])
      allow(mock_surface).to receive(:length).and_return(7794.01)
      allow(mock_image).to receive(:bounds).and_return([1243.1,2590.2,1636.2,2285.3])
      allow(obj).to receive(:surface).and_return(mock_surface)
      allow(obj).to receive(:image).and_return(mock_image)
    end
    it {expect(obj.tiles_ij(3)).not_to be_nil }
    after do
    end
  end

  describe "tile_xrange", :current => true do
    let(:zoom){ 5 }
    before do
      mock_surface = double('mock_surface')
      mock_image = double('mock_image')
      allow(mock_surface).to receive(:center).and_return([-20.28,-110.0])
      allow(mock_surface).to receive(:length).and_return(7794.01)
      allow(mock_image).to receive(:bounds).and_return([1243.1,2590.2,1636.2,2285.3])
      allow(obj).to receive(:surface).and_return(mock_surface)
      allow(obj).to receive(:image).and_return(mock_image)
    end

    it {expect(obj.tile_xrange(0)).to eql(0..0) }
    it {expect(obj.tile_xrange(1)).to eql(1..1) }
    it {expect(obj.tile_xrange(5)).to eql(21..22) }
    it {expect(obj.tile_xrange(6)).to eql(42..45) }

    after do
    end
  end

  describe "tile_yrange", :current => true do
    let(:zoom){ 5 }
    before do
      mock_surface = double('mock_surface')
      mock_image = double('mock_image')
      allow(mock_surface).to receive(:center).and_return([-20.28,-110.0])
      allow(mock_surface).to receive(:length).and_return(7794.01)
      allow(mock_image).to receive(:bounds).and_return([1243.1,2590.2,1636.2,2285.3])
      allow(obj).to receive(:surface).and_return(mock_surface)
      allow(obj).to receive(:image).and_return(mock_image)
    end
    it {expect(obj.tile_yrange(0)).to be_eql(0..0) }
    it {expect(obj.tile_yrange(0)).to be_eql(0..0) }
    it {expect(obj.tile_yrange(5)).to be_eql(4..6) }
    it {expect(obj.tile_yrange(6)).to be_eql(9..12)}
    after do
    end
  end

  describe "spots" do
  	it { expect(obj.spots).to include(spot)}
  	context "shares same surface's spots" do
	    let(:image_1) { FactoryGirl.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:image_2) { FactoryGirl.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:spot_1) { FactoryGirl.create(:spot, :attachment_file_id => image_1.id) }
	    let(:spot_2) { FactoryGirl.create(:spot, :attachment_file_id => image_2.id) }

	  	before do
	      surface.images << image_1
	      surface.images << image_2
	      spot_1
	      spot_2
	    end
	  	it { expect(obj.spots).to include(spot_1)}
    end
  end

  describe "to_region" do
  	context "shares same surface's spots" do
	    let(:image_1) { FactoryGirl.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:image_2) { FactoryGirl.create(:attachment_file, :original_geometry => "1280x1024", :affine_matrix_in_string => "[7.646e+00,-9.538e-01,3.054e+02;8.346e-01,7.890e+00,-2.109e+03;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:spot_1) { FactoryGirl.create(:spot, :attachment_file_id => image_1.id) }
	    let(:spot_2) { FactoryGirl.create(:spot, :attachment_file_id => image_2.id) }
	  	before do
	      surface.images << image_1
	      surface.images << image_2
	      spot_1
	      spot_2
	    end
	  	it { expect(obj.to_region).to match(/<polyline/)}
    end  	
  end

  describe "to_svg", :current => true do
  	subject {obj.to_svg}
 # 	it { expect(subject).to match(/<circle/)}
  	context "shares same surface's spots" do
 	    let(:image) { FactoryGirl.create(:attachment_file, :original_geometry => "1198x665", :affine_matrix_in_string => "[1.944e+01,2.527e+02,-1.727e+02;-2.546e+02,1.804e+01,1.330e+03;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:image_1) { FactoryGirl.create(:attachment_file, :original_geometry => "1280x1024", :affine_matrix_in_string => "[1.278e+01,7.878e-01,4.336e+03;-1.457e+00,1.198e+01,-5.911e+02;0.000e+00,0.000e+00,1.000e+00]") }
#	    let(:image_2) { FactoryGirl.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
	    let(:spot_1) { FactoryGirl.create(:spot, :attachment_file_id => image_1.id) }
#	    let(:spot_2) { FactoryGirl.create(:spot, :attachment_file_id => image_2.id) }
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
