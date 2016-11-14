require 'spec_helper'

describe Quantity do
  describe "class methods" do
    describe "decimal_quantity" do
      let(:quantity) { 100.0 }
      let(:quantity_unit) { "kg" }
      subject { Quantity.decimal_quantity(quantity, quantity_unit) }
      it { expect(subject.class).to eq(BigDecimal) }
      it { expect(subject).to eq(100000) }
    end

    describe "string_quantity" do
      let(:quantity) { 100.0 }
      let(:quantity_unit) { "kg" }
      subject { Quantity.string_quantity(quantity, quantity_unit) }
      it { expect(subject).to eq("100.0(kg)") }
    end

    describe "unit_exists?" do
      subject { Quantity.unit_exists?(quantity_unit) }
      context "exists" do
        let(:quantity_unit) { "kg" }
        it { expect(subject).to eq(true) }
      end
      context "not exists" do
        context "error unit" do
          let(:quantity_unit) { "kglam" }
          it { expect(subject).to eq(false) }
        end
        context "other unit" do
          let(:quantity_unit) { "km" }
          it { expect(subject).to eq(false) }
        end
      end
    end
  end

  describe "decimal_quantity" do
    let(:quantity) { 100 }
    let(:quantity_unit) { "kg" }
    let(:specimen) { FactoryGirl.create(:specimen, quantity: quantity, quantity_unit: quantity_unit) }
    subject { specimen.decimal_quantity }
    it { expect(subject.class).to eq(BigDecimal) }
    it { expect(subject).to eq(100000) }
  end

  describe "decimal_quantity_was" do
    let(:quantity) { 100 }
    let(:quantity_unit) { "kg" }
    let(:specimen) { FactoryGirl.create(:specimen, quantity: quantity, quantity_unit: quantity_unit) }
    before do
      specimen.quantity = 200
      specimen.quantity_unit = "g"
    end
    subject { specimen.decimal_quantity_was }
    it { expect(subject.class).to eq(BigDecimal) }
    it { expect(subject).to eq(100000) }
  end

  describe "string_quantity" do
    let(:quantity) { 100.0 }
    let(:quantity_unit) { "kg" }
    let(:specimen) { FactoryGirl.create(:specimen, quantity: quantity, quantity_unit: quantity_unit) }
    subject { specimen.string_quantity }
    it { expect(subject).to eq("100.0(kg)") }
  end

  describe "decimal_quantity_was" do
    let(:quantity) { 100 }
    let(:quantity_unit) { "kg" }
    let(:specimen) { FactoryGirl.create(:specimen, quantity: quantity, quantity_unit: quantity_unit) }
    before do
      specimen.quantity = 200
      specimen.quantity_unit = "g"
    end
    subject { specimen.string_quantity_was }
    it { expect(subject).to eq("100.0(kg)") }
  end
end
