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

  describe "spots" do
  	it { expect(obj.spots).to include(spot)}
  	context "shares same surface's spots" do
	    let(:image_1) { FactoryGirl.create(:attachment_file) }
	    let(:image_2) { FactoryGirl.create(:attachment_file) }
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

  describe "to_svg" do
  	subject {obj.to_svg}
  	it { expect(subject).to match(/<circle/)}
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
	  	it { expect(obj.to_svg).to match(/<circle/)}
    end
  end


end
