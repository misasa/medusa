require 'spec_helper'

describe Chemistry do

  describe "#display_name" do
    subject { chemistry.display_name }
    let(:chemistry) { FactoryGirl.build(:chemistry, measurement_item: measurement_item, unit: unit, value: value) }
    let(:measurement_item) { FactoryGirl.create(:measurement_item, unit: unit, display_in_html: display_in_html, nickname: nickname) }
    let(:unit) { FactoryGirl.create(:unit) }
    let(:value) { 1 }
    let(:display_in_html) { "HTML" }
    let(:nickname) { "nickname" }
    context "measurement_item.display_in_html is present" do
      it { expect(subject).to eq "HTML: 1.00" }
    end
    context "measurement_item.display_in_html is nil" do
      let(:display_in_html) { nil }
      it { expect(subject).to eq "nickname: 1.00" }
    end
  end
  
  describe "#unit_conversion_value" do
    subject { chemistry.unit_conversion_value(unit_name, scale) }
    let(:chemistry) { FactoryGirl.create(:chemistry, unit: unit, value: value) }
    let(:unit) { FactoryGirl.create(:unit, name: "gram_per_gram", conversion: 1) }
    let(:value) { 10 }
    let(:unit_name) { "carat" }
    let(:scale) { 1 }
    before do
      unit
      Alchemist.setup
      Alchemist.register(:mass, unit.name.to_sym, 1.to_d / unit.conversion)
    end
    context "scale is 1" do
      context "unit_name is 'carat'" do
        it { expect(subject).to eq 50.0 }# 5carat = 1gram
      end
      context "unit_name is 'ounce'" do
        let(:unit_name) { "ounce" }
        it { expect(subject).to eq 0.4 }# 1ounce = 28.34952gram
      end
    end
    context "scale is 2" do
      let(:scale) { 2 }
      context "unit_name is 'carat'" do
        it { expect(subject).to eq 50.00 }
      end
      context "unit_name is 'ounce'" do
        let(:unit_name) { "ounce" }
        it { expect(subject).to eq 0.35 }
      end
    end
    context "scale is 3" do
      let(:scale) { 3 }
      context "unit_name is 'carat'" do
        it { expect(subject).to eq 50.000 }
      end
      context "unit_name is 'ounce'" do
        let(:unit_name) { "ounce" }
        it { expect(subject).to eq 0.353 }
      end
      context "unit_name is 'gram_per_gram'" do
        let(:unit) { FactoryGirl.create(:unit, name: "centi_gram_per_gram", conversion: 100) }
        let(:value) { 51.23 }
        let(:unit_name) { "centi_gram_per_gram" }
        it { expect(subject).to eq 51.23 }
      end
    end
    context "scale is 0" do
      let(:scale) { 0 }
      context "unit_name is 'carat'" do
        it { expect(subject).to eq 50 }
      end
      context "unit_name is 'ounce'" do
        let(:unit_name) { "ounce" }
        it { expect(subject).to eq 0 }
      end
    end
    context "scale is nil" do
      let(:scale) { nil }
      context "unit_name is 'carat'" do
        it { expect(subject).to eq 50 }
      end
      context "unit_name is 'ounce'" do
        let(:unit_name) { "ounce" }
        it { expect(subject).to be_within(0.001).of(0.3527) }
      end
    end
  end

end
