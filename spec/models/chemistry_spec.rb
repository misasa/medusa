require 'spec_helper'

describe Chemistry do

  describe "test", :current => true do
    let(:specimen_1) { FactoryBot.create(:specimen) }
    let(:analysis_1) { FactoryBot.create(:analysis, specimen: specimen_1) }
    let(:analysis_2) { FactoryBot.create(:analysis, specimen: specimen_1) }
    let(:analysis_3) { FactoryBot.create(:analysis, specimen: specimen_1) }
    let(:chemistry) { FactoryBot.create(:chemistry, analysis: analysis_1, measurement_item: measurement_item, unit: unit, value: value) }
    let(:chemistry_1) { FactoryBot.create(:chemistry, analysis: analysis_2, measurement_item: measurement_item, unit: unit_2, value: value) }
    let(:chemistry_2) { FactoryBot.create(:chemistry, analysis: analysis_3, measurement_item: measurement_item, unit: unit, value: value) }
    let(:measurement_item) { FactoryBot.create(:measurement_item, unit: unit, display_in_html: display_in_html, nickname: nickname) }
    let(:measurement_item_2) { FactoryBot.create(:measurement_item, unit: unit, display_in_html: display_in_html, nickname: nickname) }
    let(:unit) { FactoryBot.create(:unit, :name => 'cg/g', :conversion => 100) }
    let(:unit_2) { FactoryBot.create(:unit, :name => 'ug/g', :conversion => 1000000) }

    let(:value) { 1 }
    let(:display_in_html) { "HTML" }
    let(:nickname) { "nickname" }
    before do
      chemistry
      chemistry_1
      chemistry_2
      #chem = Chemistry.joins(:measurement_item, :unit).where(measurement_items: {nickname: measurement_item.nickname}).select(:value, "units.name").first
      chems = Chemistry.joins(:measurement_item, :unit).where(measurement_item_id: measurement_item.id).select("chemistries.id, value, value / units.conversion as value_in_parts, units.name as unit_name ")
      summary = Chemistry.search_with_measurement_item_id(measurement_item.id).with_unit.select_summary_value_in_parts[0]
    end
    it {
      expect(Chemistry.with_measurement_item.all).not_to be_empty
    }
  end

  describe "#specimen" do
    subject { chemistry.specimen }
    let(:specimen_1) { FactoryBot.create(:specimen) }
    let(:analysis_1) { FactoryBot.create(:analysis, specimen: specimen_1) }
    let(:chemistry) { FactoryBot.create(:chemistry, analysis: analysis_1, measurement_item: measurement_item, unit: unit, value: value) }
    let(:measurement_item) { FactoryBot.create(:measurement_item, unit: unit, display_in_html: display_in_html, nickname: nickname) }
    let(:unit) { FactoryBot.create(:unit) }
    let(:value) { 1 }
    let(:display_in_html) { "HTML" }
    let(:nickname) { "nickname" }
    it {
      expect(subject).to be_eql(specimen_1)
    }
  end

  describe "#display_name" do
    subject { chemistry.display_name }
    let(:chemistry) { FactoryBot.build(:chemistry, measurement_item: measurement_item, unit: unit, value: value) }
    let(:measurement_item) { FactoryBot.create(:measurement_item, unit: unit, display_in_html: display_in_html, nickname: nickname) }
    let(:unit) { FactoryBot.create(:unit) }
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
    let(:chemistry) { FactoryBot.create(:chemistry, unit: unit, value: value) }
    let(:unit) { FactoryBot.create(:unit, name: "gram_per_gram", conversion: 1) }
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
      context "unit_name is 'centi_gram_per_gram'" do
        let(:unit) { FactoryBot.create(:unit, name: "centi_gram_per_gram", conversion: 100) }
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

  describe "#measured_value" do
    subject { chemistry.measured_value }
    let(:chemistry) { FactoryBot.create(:chemistry, unit: unit, value: value) }
    let(:unit) { FactoryBot.create(:unit, name: "parts_per_milli", conversion: conversion) }
    let(:conversion) { 1000000 }
    let(:value) { 3000000 }

    before do
      parts = FactoryBot.create(:unit, name: "parts", conversion: 1)
      Alchemist.setup
      Alchemist.register(:mass, parts.name.to_sym, 1.to_d / parts.conversion)
      Alchemist.register(:mass, unit.name.to_sym, 1.to_d / unit.conversion)
    end

    context "unit is present" do
      it "return measured value" do
        expect(subject).to eq(value / conversion)
      end
    end
    context "unit is not present" do
      before { chemistry.unit = nil }
      it "return unmeasured value" do
        expect(subject).to eq(value)
      end
    end
  end

  describe "#measured_uncertainty" do
    subject { chemistry.measured_uncertainty }
    let(:chemistry) { FactoryBot.create(:chemistry, unit: unit, uncertainty: uncertainty) }
    let(:unit) { FactoryBot.create(:unit, name: "parts_per_milli", conversion: conversion) }
    let(:conversion) { 1000000 }
    context "unit is present" do
      before do
        parts = FactoryBot.create(:unit, name: "parts", conversion: 1)
        Alchemist.setup
        Alchemist.register(:mass, parts.name.to_sym, 1.to_d / parts.conversion)
        Alchemist.register(:mass, unit.name.to_sym, 1.to_d / unit.conversion)
      end
      context "uncertainty is present" do
        let(:uncertainty) { 2000000 }
        it "return measured uncertainty" do
          expect(subject).to eq(uncertainty / conversion)
        end
      end
      context "uncertainty is not present" do
        let(:uncertainty) { nil }
        it "return nil" do
          expect(subject).to be_nil
        end
      end
    end
    context "unit is not present" do
      before { chemistry.unit = nil }
      context "uncertainty is present" do
        let(:uncertainty) { 2000000 }
        it "return unmeasured uncertainty" do
          expect(subject).to eq(chemistry.uncertainty)
        end
      end
      context "uncertainty is not present" do
        let(:uncertainty) { nil }
        it "return nil" do
          expect(subject).to be_nil
        end
      end
    end
  end

  describe "#to_pmlame" do
    subject { chemistry.to_pmlame }
    let(:chemistry) { FactoryBot.create(:chemistry, unit: unit, value: value, uncertainty: uncertainty, measurement_item: measurement_item) }
    let(:measurement_item) { FactoryBot.create(:measurement_item, unit: unit, nickname: "SiO") }
    let(:unit) { FactoryBot.create(:unit, name: "parts_per_milli", conversion: conversion) }
    let(:conversion) { 1000000 }
    let(:value) { 3000000 }
    let(:uncertainty) { 2000000 }

    before do
      parts = FactoryBot.create(:unit, name: "parts", conversion: 1)
      Alchemist.setup
      Alchemist.register(:mass, parts.name.to_sym, 1.to_d / parts.conversion)
      Alchemist.register(:mass, unit.name.to_sym, 1.to_d / unit.conversion)
    end

    context "when it has measured value and measured uncertainty," do
      it "return hash what has measured value and uncertainty value" do
        expect(subject).to eq({"SiO" => 3.0, "SiO_error" => 2.0})
      end
    end

    context "when measured_value is nil," do
      it "return hash what has measured value and uncertainty value" do
        allow(chemistry).to receive(:measured_value).and_return(nil)
        expect(subject).to eq({"SiO" => nil, "SiO_error" => 2.0})
      end
    end

    context "when measured_uncertainty is nil," do
      it "return hash what has measured value and uncertainty value" do
        allow(chemistry).to receive(:measured_uncertainty).and_return(nil)
        expect(subject).to eq({"SiO" => 3.0, "SiO_error" => nil})
      end
    end

  end

end
