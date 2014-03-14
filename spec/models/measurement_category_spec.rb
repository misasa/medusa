require 'spec_helper'

describe MeasurementCategory do

  describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:measurement_category, name: name) }
      context "is presence" do
        let(:name) { "sample_measurement_category" }
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
      context "is duplicate" do
        let(:name) { "name" }
        before { FactoryGirl.create(:measurement_category, name: name) }
        it { expect(obj).not_to be_valid }
      end
    end
  end

  describe "#export_headers" do
    subject { obj.export_headers }
    let(:obj) { FactoryGirl.build(:measurement_category) }
    let(:nicknames_with_unit) { ["foo"] }
    let(:nicknames) { ["bar", "baz"] }
    before do
      allow(obj).to receive(:nicknames_with_unit).and_return(nicknames_with_unit)
      allow(obj).to receive(:nicknames).and_return(nicknames)
    end
    it { expect(subject).to eq ["foo", "bar_error", "baz_error"] }
  end

  describe "#nicknames_with_unit" do
    subject { obj.send(:nicknames_with_unit) }
    let(:obj) { FactoryGirl.build(:measurement_category) }
    let(:unit) { FactoryGirl.create(:unit, name: "unit") }
    let(:nicknames) { ["bar", "baz"] }
    before do
      allow(obj).to receive(:unit).and_return(unit)
      allow(obj).to receive(:nicknames).and_return(nicknames)
    end
    context "unit is presence" do
      it { expect(subject).to eq ["bar_in_unit", "baz_in_unit"] }
    end
    context "unit is nil" do
      let(:unit) { nil }
      it { expect(subject).to eq nicknames }
    end
  end

  describe "#nicknames" do
    subject { obj.send(:nicknames) }
    let(:obj) { FactoryGirl.create(:measurement_category) }
    let(:measurement_item_1) { FactoryGirl.create(:measurement_item, nickname: "foo") }
    let(:measurement_item_2) { FactoryGirl.create(:measurement_item, nickname: "bar") }
    context "obj not associate measurement_item" do
      before { measurement_item_1 }
      it { expect(subject).to eq [] }
    end
    context "obj associate measurement_item" do
      before do
        obj.measurement_items << measurement_item_1
        obj.measurement_items << measurement_item_2
      end
      it { expect(subject).to eq ["foo", "bar"] }
    end
  end
end
