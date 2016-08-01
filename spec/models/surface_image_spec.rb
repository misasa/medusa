require 'spec_helper'

describe SurfaceImage do
  let(:surface) { FactoryGirl.create(:surface) }
  let(:image) { FactoryGirl.create(:attachment_file) }

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

  describe "to_svg" do
  	subject {obj.to_svg}
  	it { expect(subject).to match(/<circle/)}
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
	  	it { expect(obj.to_svg).to match(/<circle/)}
    end
  end


end
