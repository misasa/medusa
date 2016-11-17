require 'spec_helper'

describe Surface do
  describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:surface, name: name) }
      context "is presence" do
        let(:name) { "surface-1" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:name) { "" }
        it { expect(obj).not_to be_valid }
      end
      describe "length" do
        context "is 255 characters" do
          let(:name) { "a" * 255 }
          it { expect(obj).to be_valid }
        end
        context "is 256 characters" do
          let(:name) { "a" * 256 }
          it { expect(obj).not_to be_valid }
        end
      end
    end
  end

  describe "prop" do
  	let(:obj){ FactoryGirl.create(:surface) }
  	it { expect(obj.global_id).not_to be_nil }
  end

  describe "images <<" do
    subject { obj.images << image }
  	let(:obj){ FactoryGirl.create(:surface) }
    let(:image){ FactoryGirl.create(:attachment_file, data_content_type: data_content_type)}
    let(:data_content_type) { "image/jpeg" }
    before do
    	obj
    	image
    end
    context "image file" do
      let(:data_content_type) { "image/jpeg" }
      before { subject }
      it { expect(obj.images.exists?(id: image.id)).to eq true}
    end

    context "not image file" do
      let(:data_content_type) { "application/pdf" }
      it { expect{subject}.to raise_error(ActiveRecord::RecordInvalid)}
    end
  end

  describe "spots", :current => true do
    #it { expect(obj.spots).to include(spot)}
    context "shares same surface's spots" do
      let(:obj){ FactoryGirl.create(:surface) }
      let(:image_1) { FactoryGirl.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
      let(:image_2) { FactoryGirl.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
      let(:spot_1) { FactoryGirl.create(:spot, :attachment_file_id => image_1.id) }
      let(:spot_2) { FactoryGirl.create(:spot, :attachment_file_id => image_2.id) }

      before do
        obj.images << image_1
        obj.images << image_2
        spot_1
        spot_2
      end
      it { expect(obj.spots).to include(spot_1)}
    end
  end


  describe "to_pml", :current => true do
    context "shares same surface's spots" do
      let(:obj){ FactoryGirl.create(:surface) }
      let(:image_1) { FactoryGirl.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
      let(:image_2) { FactoryGirl.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
      let(:analysis_1){ FactoryGirl.create(:analysis)}
      let(:analysis_2){ FactoryGirl.create(:analysis)}
      let(:analysis_3){ FactoryGirl.create(:analysis)}

      let(:spot_1) { FactoryGirl.create(:spot, :attachment_file_id => image_1.id, target_uid: analysis_1.record_property.global_id) }
      let(:spot_2) { FactoryGirl.create(:spot, :attachment_file_id => image_2.id, target_uid: analysis_2.record_property.global_id) }
      let(:spot_3) { FactoryGirl.create(:spot, :attachment_file_id => image_2.id, target_uid: analysis_3.record_property.global_id)}

      before do
        obj.images << image_1
        obj.images << image_2
        spot_1
        spot_2
        spot_3
      end
      it { expect(obj.to_pml).to match(/<?xml/)}
    end
  end

end
