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
    pending("") do
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
    it { expect(subject).to eql(image_2)}
    context "when image was deleted" do
      before do
        image.destroy
      end
      it { expect(subject).to eql(image_2)}
      it { expect(obj.surface_images.count).to eq(1) }
    end
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

  describe "initial_corners_for" do
    subject { surface.initial_corners_for(image)  }
    let(:surface){ FactoryGirl.create(:surface) }
    let(:center) {[6800,-350]}
    let(:length) {3787.006}
    let(:width) {760}
    let(:height) {700}

    let(:image) { FactoryGirl.create(:attachment_file, affine_matrix: nil) }
    before do
      allow(image).to receive(:width).and_return(width)
      allow(image).to receive(:height).and_return(height)
      allow(surface).to receive(:center).and_return(center)
      allow(surface).to receive(:length).and_return(length)
    end
    it { expect(subject.size).to be_eql(4)}
  end

  describe "bounds_on_map" do
    let(:surface){ FactoryGirl.create(:surface, center_x: center_x, center_y: center_y, width: width, height: height) }
    let(:center_x){ 21.286 }
    let(:center_y){ -110}
    let(:width){ 7659.504 }
    let(:height){ 7794.012 }

    let(:left) {-3808.472}
    let(:upper) {3787.006}
    let(:right) {3851.032}
    let(:bottom) {-4007.006}
    before do
      allow(surface).to receive(:image_bounds).and_return([left, upper, right, bottom])
    end

    it { expect(surface.coords_on_map([1058.244, 2720.475])[0]).to be_within(0.1).of(164.26)}
    it { expect(surface.coords_on_map([1058.244, 2720.475])[1]).to be_within(0.1).of(35.03)}
    it { expect(surface.coords_on_map([[1058.244, 2720.475], [1821.756, 2125.525]])[0][0]).to be_within(0.1).of(164.26)}
    it { expect(surface.coords_on_map([[1058.244, 2720.475], [1821.756, 2125.525]])[0][1]).to be_within(0.1).of(35.03)}
   it { expect(surface.coords_on_map([[1058.244, 2720.475], [1821.756, 2125.525]])[1][0]).to be_within(0.1).of(189.34)}
    it { expect(surface.coords_on_map([[1058.244, 2720.475], [1821.756, 2125.525]])[1][1]).to be_within(0.1).of(54.57)}


    
  end

  describe "tile_at" do
    let(:obj){ FactoryGirl.create(:surface) }
    pending("...") do
    #let(:center_x){ 21.286 }
    #let(:center_y){ -110}
    #let(:width){ 7659.504 }
    #let(:height){ 7794.012 }
    let(:left) {-3808.472}
    let(:upper) {3787.006}
    let(:right) {3851.032}
    let(:bottom) {-4007.006}
#    let(:zoom){ 5 }
    before do      
      allow(obj).to receive(:image_bounds).and_return([left, upper, right, bottom])
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
    context "with zooms" do
      it {expect(obj.tile_at(1.upto(6),[1440,2423])).to eql([[1,0],[2,0],[5,1],[10,2],[21,5],[43,11]])}
    end

    end
  end


  describe "length" do
    subject {obj.length}
    let(:obj){ FactoryGirl.create(:surface, width: width, height: height) }
    let(:width){ 80000 }
    let(:height){ 50000 }
    it { expect(subject).to be_within(0.1).of(width) }
    context "width is blank" do
      let(:width){ nil }
      let(:height){ 50000 }
      it { expect(subject).to be_within(0.1).of(height) }
    end
    context "height is blank" do
      let(:width){ 80000 }
      let(:height){ nil }
      it { expect(subject).to be_within(0.1).of(width) }
    end
    context "width and height are blank" do
      let(:width){ nil }
      let(:height){ nil }
      it { expect(subject).to be_within(0.1).of(100000) }
    end
  end


  describe "image_bounds_center" do
    subject {obj.image_bounds_center}
    let(:obj){ FactoryGirl.create(:surface) }
    before do
      s_image_1 = double('surface_image_1', :bounds => [-100,100,100,-100])
      s_image_2 = double('surface_image_2', :bounds => [-120,120,-20,20])
      s_image_3 = double('surface_image_2', :bounds => [-10,10,110,-110])
      allow(obj).to receive(:surface_images).and_return([s_image_1,s_image_2,s_image_3])
      obj.save
    end
    it { expect(subject).to eql([-5,5])}
  end

  describe "center" do
    subject {obj.center}

    let(:obj){ FactoryGirl.create(:surface, center_x: center_x, center_y: center_y) }
    let(:center_x){ 2.0 }
    let(:center_y){ 5.0 }
    it { expect(subject).to match_array([center_x,center_y])}
    context "center_x is nil" do
      let(:center_x){ nil }
      let(:center_y){ 5.0 }
      it { expect(subject).to match_array([0.0,center_y])}
    end
    context "center_y is nil" do
      let(:center_x){ 2.0 }
      let(:center_y){ nil }
      it { expect(subject).to match_array([center_x,0.0])}
    end
    context "center_x and center y are nil" do
      let(:center_x){ nil }
      let(:center_y){ nil }
      it { expect(subject).to match_array([0.0,0.0])}
    end
    context "center_x and center y are empty" do
      let(:center_x){ ""}
      let(:center_y){ ""}
      it { expect(subject).to match_array([0.0,0.0])}
    end
    context "without init" do
      subject {obj.center}
      let(:obj){ FactoryGirl.create(:surface) }
      it { expect(subject).to match_array([0.0,0.0])}      
    end

    context "with calibrated images" do
      subject {obj.center}
      let(:obj){ FactoryGirl.create(:surface) }
      before do
        s_image_1 = double('surface_image_1', :bounds => [-100,100,100,-100])
        s_image_2 = double('surface_image_2', :bounds => [-120,120,-20,20])
        s_image_3 = double('surface_image_2', :bounds => [-10,10,110,-110])
        allow(obj).to receive(:surface_images).and_return([s_image_1,s_image_2,s_image_3])
        obj.save
      end
      #it { expect(subject).to eql([-120,110])}
      it { expect(subject).to eql([0.0,0.0])}
    end
  end



  describe "bbox" do
    subject{ obj.bbox }
    let(:obj){ FactoryGirl.create(:surface, center_x: center_x, center_y: center_y, width: width, height: height) }
    let(:center_x){ 10000.0 }
    let(:center_y){ 10000.0 }
    let(:width){ 50000 }
    let(:height){ 80000 }
    before do
      obj
    end
    it { expect(subject).to match_array([-30000,50000,50000,-30000])}
    context "with nil paramters" do
      let(:center_x){ nil }
      let(:center_y){ nil }
      let(:width){ nil }
      let(:height){ nil }
      it { expect(subject).to match_array([-50000,50000,50000,-50000])}
    end
  end

  describe "image_bounds" do
    #it { expect(obj.spots).to include(spot)}
      let(:obj){ FactoryGirl.create(:surface) }
      context "with calibrated images" do
        before do
          s_image_1 = double('surface_image_1', :bounds => [-100,100,100,-100])
          s_image_2 = double('surface_image_2', :bounds => [-120,120,-20,20])
          s_image_3 = double('surface_image_2', :bounds => [-10,10,110,-110])
          allow(obj).to receive(:surface_images).and_return([s_image_1,s_image_2,s_image_3])
        end
        it { expect(obj.image_bounds).to eql([-120,120,110,-110])}
      end
      context "with calibrated and uncalibrated images" do
        before do
          s_image_1 = double('surface_image_1', :bounds => [-100,100,100,-100])
          s_image_2 = double('surface_image_2', :bounds => [nil,nil,nil,nil])
          s_image_3 = double('surface_image_2', :bounds => [-10,10,110,-110])
          allow(obj).to receive(:surface_images).and_return([s_image_1,s_image_2,s_image_3])
        end
        it { expect(obj.image_bounds).to be_an_instance_of(Array)}
        it { expect(obj.image_bounds).to match_array([-100,100,110,-110])}
      end

      context "with uncalibrated images" do
        before do
          s_image_1 = double('surface_image_1', :bounds => nil)
          s_image_2 = double('surface_image_2', :bounds => [nil,nil,nil,nil])
          s_image_3 = double('surface_image_2', :bounds => [-10,nil,110,-110])
          allow(obj).to receive(:surface_images).and_return([s_image_1,s_image_2,s_image_3])
        end
        it { expect(obj.image_bounds).to match_array([nil,nil,nil,nil])}
      end
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
