# -*- coding: utf-8 -*-
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

  describe "publish!" do
    subject { surface.publish!  }
    let(:surface){ FactoryGirl.create(:surface) }
    before do
      surface
    end
    it { expect{ subject }.not_to raise_error }
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


  describe "first_image" do
    subject { obj.first_image }
    let(:obj){ FactoryGirl.create(:surface) }
    let(:image){ FactoryGirl.create(:attachment_file, data_content_type: data_content_type)}
    let(:image_2){ FactoryGirl.create(:attachment_file, data_content_type: data_content_type)}
    let(:data_content_type) { "image/jpeg" }
    before do
      obj
      obj.images << image
      obj.images << image_2  
    end
    it { expect(subject).to eql(image)}
    context "when image was deleted" do
      before do
        image.destroy
      end
      it { expect(subject).to eql(image_2)}
      it { expect(obj.surface_images.count).to eq(1) }
    end
  end



  describe "spots" do
    #it { expect(obj.spots).to include(spot)}
    context "shares same surface's spots" do
      let(:obj){ FactoryGirl.create(:surface) }
      let(:image_1) { FactoryGirl.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
      let(:image_2) { FactoryGirl.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
      let(:spot_1) { FactoryGirl.create(:spot, :attachment_file_id => image_1.id) }
      let(:spot_2) { FactoryGirl.create(:spot, :attachment_file_id => image_2.id) }

      before do
        allow(image_1).to receive(:spots).and_return([spot_1])
        allow(image_2).to receive(:spots).and_return([spot_2])
        obj.images << image_1
        obj.images << image_2
        spot_1
        spot_2
      end
      it { expect(obj.spots).to include(spot_1)}
    end
  end


  describe "tile_at", :current => true do
    let(:obj){ FactoryGirl.create(:surface) }
    let(:left) {-3808.472}
    let(:upper) {3787.006}
    let(:right) {3851.032}
    let(:bottom) {-4007.006}
#    let(:zoom){ 5 }
    before do
      allow(obj).to receive(:bounds).and_return([left, upper, right, bottom])
    end

    it {expect(obj.tile_at(1,[-3808.473,3787.007])).to eql([0,0]) }
    it {expect(obj.tile_at(1,[-3808.471,3787.005])).to eql([0,0]) }
    it {expect(obj.tile_at(1,[3851.031,-4007.005])).to eql([1,1])}
    it {expect(obj.tile_at(1,[3851.033,-4007.007])).to eql([1,1])}
    it {expect(obj.tile_at(1,[1440,2423])).to eql([1,0])}
    it {expect(obj.tile_at(2,[1440,2423])).to eql([2,0])}
    it {expect(obj.tile_at(3,[1440,2423])).to eql([5,1])}
    it {expect(obj.tile_at(4,[1440,2423])).to eql([10,2])}
    it {expect(obj.tile_at(5,[1440,2423])).to eql([21,5])}
    it {expect(obj.tile_at(6,[1440,2423])).to eql([43,11])}
    

    after do
    end
  end

  describe "bounds" do
    #it { expect(obj.spots).to include(spot)}
      let(:obj){ FactoryGirl.create(:surface) }
      let(:image_1) { FactoryGirl.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
      let(:image_2) { FactoryGirl.create(:attachment_file, :affine_matrix_in_string => "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]") }
      before do
        obj.images << image_1
        obj.images << image_2
      end
      it { expect(obj.bounds).to be_an_instance_of(Array)}
      it { expect(obj.center).to be_an_instance_of(Array)}
  end


  describe "to_pml" do
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
        allow(image_1).to receive(:spots).and_return([spot_1])
        allow(image_2).to receive(:spots).and_return([spot_2, spot_3])
        obj.images << image_1
        obj.images << image_2
        spot_1
        spot_2
        spot_3
      end
      it { expect(obj.to_pml).to match(/<?xml/)}
      it { expect(obj.to_pml).to match(/<attachment_file_global_id>*.+<\/attachment_file_global_id>/)}
      it { expect(obj.to_pml).to match(/<attachment_file_path>*.+<\/attachment_file_path>/)}
    end
  end

  describe "pml_elements" do
    let(:obj){ FactoryGirl.create(:surface, globe: globe?) }

    let(:spot_1){ FactoryGirl.create(:spot, name: "spot1", attachment_file_id: surface_image.image_id) }
    let(:spot_2){ FactoryGirl.create(:spot, name: "spot2", attachment_file_id: surface_image.image_id) }
    let(:surface_image){ FactoryGirl.create(:surface_image, surface_id: obj.id) }

    let(:place_1){ FactoryGirl.create(:place, name: "place1") }
    let(:place_2){ FactoryGirl.create(:place, name: "place2") }
    let(:specimen_1){ FactoryGirl.create(:specimen, name: "specimen1") }
    let(:specimen_2){ FactoryGirl.create(:specimen, name: "specimen2") }
    let(:specimen_3){ FactoryGirl.create(:specimen, name: "specimen3") }

    let(:bib){ FactoryGirl.create(:bib) }
    let(:analysis_1){ FactoryGirl.create(:analysis, name: "分析_1", specimen_id: specimen_1.id)}
    let(:analysis_2){ FactoryGirl.create(:analysis, name: "分析_2", specimen_id: specimen_2.id)}
    let(:analysis_3){ FactoryGirl.create(:analysis, name: "分析_3", specimen_id: specimen_3.id)}
    let(:analysis_4){ FactoryGirl.create(:analysis, name: "分析_4", specimen_id: nil)}
    let(:analysis_5){ FactoryGirl.create(:analysis, name: "分析_5", specimen_id: nil)}
    let(:analysis_6){ FactoryGirl.create(:analysis, name: "分析_6", specimen_id: nil)}
    let(:analysis_7){ FactoryGirl.create(:analysis, name: "分析_7", specimen_id: nil)}

    before do
      specimen_1.analyses << analysis_1
      specimen_2.analyses << analysis_2
      specimen_3.analyses << analysis_3

      bib.analyses << analysis_4
      bib.analyses << analysis_5

      allow(spot_1).to receive(:target).and_return(analysis_6)
      allow(spot_2).to receive(:target).and_return(analysis_7)

      place_1.specimens << specimen_1
      place_2.specimens << specimen_2
      place_2.specimens << specimen_3
      place_2.bibs << bib
    end
    context "surface is globe," do
      let(:globe?){ true }
      it "returns place's pmlame elements." do
        expect(obj.pml_elements).to match_array([analysis_1, analysis_2, analysis_3, analysis_4, analysis_5])
      end
    end
    context "surface is NOT globe," do
      let(:globe?){ false }
      it "returns spot's pmlame elements." do
        expect(obj.pml_elements).to match_array([spot_1, spot_2])
      end
    end
  end

end
