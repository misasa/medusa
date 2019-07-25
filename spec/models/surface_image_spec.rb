require 'spec_helper'

describe SurfaceImage do
  let(:surface) { FactoryGirl.create(:surface) }
  let(:image) { FactoryGirl.create(:attachment_file, :original_geometry => "4096x3415", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
  let(:obj) { FactoryGirl.create(:surface_image, :surface_id => surface.id, :image_id => image.id)}
  
  describe "scope", :current => true do
    describe "wall" do
      let(:image_1){ FactoryGirl.create(:attachment_file) }
      let(:wall_image){ FactoryGirl.create(:surface_image, :wall => true, :surface_id => surface.id, :image_id => image_1.id) }
      let(:image_2){ FactoryGirl.create(:attachment_file) }
      let(:overlay_image){ FactoryGirl.create(:surface_image, :surface_id => surface.id, :image_id => image_2.id) }
      subject { SurfaceImage.wall }
      it { expect(subject).to include(wall_image) }
      it { expect(subject).not_to include(overlay_image) }
    end

    describe "base" do
      let(:image_1){ FactoryGirl.create(:attachment_file) }
      let(:wall_image){ FactoryGirl.create(:surface_image, :wall => true, :surface_id => surface.id, :image_id => image_1.id) }
      let(:image_2){ FactoryGirl.create(:attachment_file) }
      let(:overlay_image){ FactoryGirl.create(:surface_image, :surface_id => surface.id, :image_id => image_2.id) }
      subject { SurfaceImage.base }
      it { expect(subject).to include(wall_image) }
      it { expect(subject).not_to include(overlay_image) }
    end

    describe "overlay" do
      let(:image_1){ FactoryGirl.create(:attachment_file) }
      let(:wall_image){ FactoryGirl.create(:surface_image, :wall => true, :surface_id => surface.id, :image_id => image_1.id) }
      let(:image_2){ FactoryGirl.create(:attachment_file) }
      let(:overlay_image){ FactoryGirl.create(:surface_image, :surface_id => surface.id, :image_id => image_2.id) }
      subject { SurfaceImage.overlay }
      it { expect(subject).not_to include(wall_image) }
      it { expect(subject).to include(overlay_image) }
    end

    describe "calibrated" do
      subject { SurfaceImage.calibrated }
      let(:image_1){ FactoryGirl.create(:attachment_file) }
      let(:calibrated_image){ FactoryGirl.create(:surface_image, :wall => true, :surface_id => surface.id, :image_id => image_1.id) }
      let(:image_2){ FactoryGirl.create(:attachment_file, :affine_matrix => nil) }
      let(:uncalibrated_image){ FactoryGirl.create(:surface_image, :surface_id => surface.id, :image_id => image_2.id) }
      let(:image_3){ FactoryGirl.create(:attachment_file, :affine_matrix => []) }
      let(:uncalibrated_image_2){ FactoryGirl.create(:surface_image, :surface_id => surface.id, :image_id => image_3.id) }
      it { expect(subject).to include(calibrated_image) }
      it { expect(subject).not_to include(uncalibrated_image) }
      it { expect(subject).not_to include(uncalibrated_image_2) }
    end

  end


  describe "#width" do
    subject { obj.width }
    context "with left and right attributes" do
      let(:obj) {FactoryGirl.create(:surface_image, :surface_id => surface.id, left: left, right: right)}
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
      let(:obj) {FactoryGirl.create(:surface_image, :surface_id => surface.id, upper: upper, bottom: bottom)}
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


  describe "#bonds" do
    subject { obj.bounds }
    let(:obj) { FactoryGirl.create(:surface_image, :surface_id => surface.id)}
    let(:left) {-3808.472}
    let(:upper) {3787.006}
    let(:right) {3851.032}
    let(:bottom) {-4007.006}
    context "with attributes" do
      let(:obj) {FactoryGirl.create(:surface_image, :surface_id => surface.id, left: left, upper: upper, right: right, bottom: bottom)}
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
      let(:image) { FactoryGirl.create(:attachment_file, :original_geometry => "40960x34150", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
      it { expect(subject).to eq(8)  }
    end

    context "with small image" do
      let(:image) { FactoryGirl.create(:attachment_file, :original_geometry => "410x342", :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
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


  context "with spot" do

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

  describe "to_svg" do
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
end
