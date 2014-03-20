require 'spec_helper'

describe Analysis do

  describe "constants" do
    describe "PERMIT_IMPORT_TYPES" do
      subject { Analysis::PERMIT_IMPORT_TYPES }
      it { expect(subject).to include("text/plain", "text/csv", "application/csv") }
    end
  end

  describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:analysis, name: name) }
      context "is presence" do
        let(:name) { "sample_analysis" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:name) { "" }
        it { expect(obj).not_to be_valid }
      end
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

  describe "#chemistry_summary" do
    let(:analysis) { FactoryGirl.create(:analysis) }
    let(:chemistries) { [chemistry_1, chemistry_2] }
    let(:chemistry_1) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: measurement_item_1) }
    let(:chemistry_2) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: measurement_item_2) }
    let(:measurement_item_1) { FactoryGirl.create(:measurement_item) }
    let(:measurement_item_2) { FactoryGirl.create(:measurement_item) }
    let(:display_name_1) { "display_name_1" }
    let(:display_name_2) { "display_name_2" }
    before do
      allow(analysis).to receive(:chemistries).and_return(chemistries)
      allow(chemistry_1).to receive(:display_name).and_return(display_name_1)
      allow(chemistry_2).to receive(:display_name).and_return(display_name_2)
    end
    context "method call with no argument" do
      subject { analysis.chemistry_summary }
      context "chemistry.measurement_item is present" do
        it { expect(subject).to eq "display_name_1, display_name_2" }
      end
      context "chemistry.measurement_item is present and display_name is 90 characters" do
        let(:display_name_1) { "a" * 90 }
        let(:display_name_2) { "b" * 90 }
        it { expect(subject).to eq(display_name_1 + ", " + "bbbbb...") }
      end
      context "chemistry.measurement_item is blank" do
        let(:chemistry_1) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: nil) }
        let(:chemistry_2) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: nil) }
        it { expect(subject).to eq "" }
      end
    end
    context "method call with 50" do
      subject { analysis.chemistry_summary(50) }
      context "chemistry.measurement_item is present" do
        it { expect(subject).to eq "display_name_1, display_name_2" }
      end
      context "chemistry.measurement_item is present and display_name is 90 characters" do
        let(:display_name_1) { "a" * 90 }
        let(:display_name_2) { "b" * 90 }
        it { expect(subject).to eq("a" * 47 + "...") }
      end
      context "chemistry.measurement_item is blank" do
        let(:chemistry_1) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: nil) }
        let(:chemistry_2) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: nil) }
        it { expect(subject).to eq "" }
      end
    end
  end

  describe "stone_global_id" do
    let(:stone){FactoryGirl.create(:stone)}
    let(:analysis){FactoryGirl.create(:analysis)}
    context "get" do
      context "stone_id is nil" do
        before{analysis.stone_id = nil}
        it {expect(analysis.stone_global_id).to be_blank}
      end
      context "stone_id is ng" do
        before{analysis.stone_id = 0}
        it {expect(analysis.stone_global_id).to be_blank}
      end
      context "stone_id is ok" do
        before{analysis.stone_id = stone.id}
        it {expect(analysis.stone_global_id).to eq stone.global_id}
      end
    end
    context "set" do
      context "stone_global_id is nil" do
        before{analysis.stone_global_id = nil}
        it {expect(analysis.stone).to be_blank}
      end
      context "stone_global_id is ng" do
        before{analysis.stone_global_id = "xxxxxxxxxxxxxxxxx"}
        it {expect(analysis.stone).to be_blank}
      end
      context "stone_global_id is ok" do
        before{analysis.stone_global_id = stone.global_id}
        it {expect(analysis.stone).to eq stone}
      end
    end
  end

  describe "#device_name=" do
    before { analysis.device_name = name }
    let(:analysis) { FactoryGirl.build(:analysis, device: nil) }
    context "name is exist device name" do
      let(:name) { device.name }
      let(:device) { FactoryGirl.create(:device) }
      it { expect(analysis.device_id).to eq device.id }
    end
    context "name is not device name" do
      let(:name) { "hoge" }
      it { expect(analysis.device_id).to be_nil }
    end
  end

  describe "#technique_name=" do
    before { analysis.technique_name = name }
    let(:analysis) { FactoryGirl.build(:analysis, technique: nil) }
    context "name is exist technique name" do
      let(:name) { technique.name }
      let(:technique) { FactoryGirl.create(:technique) }
      it { expect(analysis.technique_id).to eq technique.id }
    end
    context "name is not technique name" do
      let(:name) { "hoge" }
      it { expect(analysis.technique_id).to be_nil }
    end
  end

  describe ".import_csv" do
    subject { Analysis.import_csv(file) }
    context "file is nil" do
      let(:file) { nil }
      it { expect(subject).to be_nil }
    end
    context "file is present" do
      let(:file) { double(:file) }
      let(:objects) { [analysis] }
      before do
        allow(file).to receive(:content_type).and_return(content_type)
        allow(Analysis).to receive(:build_objects_from_csv).with(file).and_return(objects)
      end
      context "content_type is 'csv'" do
        let(:content_type) { 'text/csv' }
        context "objects is all valid" do
          let(:analysis) { FactoryGirl.build(:analysis) }
          it { expect(subject).to be_present }
        end
        context "object is invalid" do
          let(:analysis) { FactoryGirl.build(:analysis, name: nil) }
          it { expect(subject).to eq false }
        end
      end
      context "content_type is not 'csv'" do
        let(:content_type) { 'image/png' }
        context "objects is all valid" do
          let(:analysis) { FactoryGirl.build(:analysis) }
          it { expect(subject).to be_nil }
        end
        context "object is invalid" do
          let(:analysis) { FactoryGirl.build(:analysis, name: nil) }
          it { expect(subject).to be_nil }
        end
      end
    end
  end

  describe ".build_objects_from_csv" do
    subject { Analysis.build_objects_from_csv(file) }
    let(:file) { double(:file) }
    let(:csv_read) { [["header ", nil], [row_1], [row_2]] }
    let(:row_1) { "row_1" }
    let(:row_2) { "row_2" }
    let(:object_1) { double(:object_1) }
    let(:object_2) { double(:object_2) }
    before do
      allow(file).to receive(:read)
      allow(CSV).to receive(:parse).and_return(csv_read)
      allow(Analysis).to receive(:set_object).with(["header_"], [row_1]).and_return(object_1)
      allow(Analysis).to receive(:set_object).with(["header_"], [row_2]).and_return(object_2)
    end
    it { expect(subject).to eq [object_1, object_2] }
  end

  pending "set_object" do
  end

  describe "#to_castemls" do
    subject { Analysis.to_castemls(objs) }
    let(:obj) { FactoryGirl.create(:analysis) }
    let(:obj2) { FactoryGirl.create(:analysis) }
    let(:objs){ [obj,obj2]}
    it {expect(subject).to be_present}
  end

  describe ".get_spot" do
    subject { obj.get_spot }
    let(:user){FactoryGirl.create(:user)}
    let(:obj) {FactoryGirl.create(:analysis) }
    let(:spot1){FactoryGirl.create(:spot,target_uid: global_id)}
    let(:spot2){FactoryGirl.create(:spot,target_uid: global_id)}
    before{User.current = user}
    context "no spots" do
      let(:global_id){"xxx"}
      before do
        obj
        spot1
      end
      it{expect(subject).to be_nil}
    end
    context "1 spot exists" do
      let(:global_id){obj.global_id}
      before do
        obj
        spot1
      end
      it{expect(subject).to eq spot1}
    end
    context "2 spot exists" do
      let(:global_id){obj.global_id}
      before do
        obj
        spot1
        spot2
      end
      it{expect(subject).to eq spot1}
    end
  end
    
end
