require 'spec_helper'

describe Analysis do

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
end
