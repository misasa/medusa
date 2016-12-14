require 'spec_helper'

describe HasQuantity do
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
    it { expect(subject).to eq("100.0 kg") }
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
    it { expect(subject).to eq("100.0 kg") }
  end

  describe "quantity_unit_exists" do
    let(:obj) { FactoryGirl.build(:specimen, quantity: quantity, quantity_unit: quantity_unit) }
    let(:quantity) { 100 }
    before { obj.quantity_unit_exists }
    context "exists unit" do
      let(:quantity_unit) { "kilog" }
      it { expect(obj.errors.full_messages).to be_empty }
    end
    context "not exists unit" do
      let(:quantity_unit) { "kelog" }
      it { expect(obj.errors.full_messages).to eq ["Quantity unit \"kelog\" does not exist"] }
    end
  end
end
