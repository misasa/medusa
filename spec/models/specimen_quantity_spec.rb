require 'spec_helper'

describe SpecimenQuantity do

  describe "validates" do
    describe "quantity" do
      let(:obj) { FactoryGirl.build(:specimen_quantity, quantity: quantity) }
      context "num" do
        let(:quantity){ "1" }
        it { expect(obj).to be_valid }
        context "0" do
          let(:quantity){ "0" }
          it { expect(obj).to be_valid }
        end
        context "-1" do
          let(:quantity){ "-1" }
          it { expect(obj).not_to be_valid }
        end
      end
      context "str" do
        let(:quantity){ "a" }
        it { expect(obj).not_to be_valid }
      end
    end
  end

  describe "class methods" do
    describe "point" do
      let(:before_specimen) { FactoryGirl.create(:specimen, quantity: 100, quantity_unit: "kg") }
      let(:before_specimen_quantity) { FactoryGirl.create(:specimen_quantity, specimen: before_specimen, quantity: 100, quantity_unit: "kg") }
      let(:divide) { FactoryGirl.create(:divide, before_specimen_quantity: before_specimen_quantity, updated_at: time, divide_flg: divide_flg, log: "log") }
      let(:specimen) { FactoryGirl.create(:specimen, quantity: 100, quantity_unit: "kg") }
      let(:time) { Time.zone.local(2016, 11,12) }
      let(:divide_flg) { true }
      subject { SpecimenQuantity.point(divide, 100000.0, "100.0(kg)") }
      context "divide_flg true" do
        let(:divide_flg) { true }
        it do
          expect(subject.class).to eq(Hash)
          expect(subject[:id]).to eq(divide.id)
          expect(subject[:x]).to eq(divide.chart_updated_at)
          expect(subject[:y]).to eq(100000.0)
          expect(subject[:date_str]).to eq("2016/11/12 00:00:00")
          expect(subject[:quantity_str]).to eq("100.0(kg)")
          expect(subject[:before_specimen_name]).to eq(before_specimen.name)
          expect(subject[:comment]).to eq("log")
        end
      end
      context "divide_flg false" do
        let(:divide_flg) { false }
        it do
          expect(subject.class).to eq(Hash)
          expect(subject[:id]).to eq(divide.id)
          expect(subject[:x]).to eq(divide.chart_updated_at)
          expect(subject[:y]).to eq(100000.0)
          expect(subject[:date_str]).to eq("2016/11/12 00:00:00")
          expect(subject[:quantity_str]).to eq("100.0(kg)")
          expect(subject[:before_specimen_name]).to be_nil
          expect(subject[:comment]).to eq("log")
        end
      end
    end
  end

  describe "instance methods" do
    describe "point" do
      let(:before_specimen) { FactoryGirl.create(:specimen, quantity: 100, quantity_unit: "kg") }
      let(:before_specimen_quantity) { FactoryGirl.create(:specimen_quantity, specimen: before_specimen, quantity: 100, quantity_unit: "kg") }
      let(:divide) { FactoryGirl.create(:divide, before_specimen_quantity: before_specimen_quantity, updated_at: time, divide_flg: divide_flg, log: "log") }
      let(:specimen_quantity) { FactoryGirl.create(:specimen_quantity, quantity: 100, quantity_unit: "kg", divide: divide) }
      let(:time) { Time.zone.local(2016, 11,12) }
      let(:divide_flg) { true }
      subject { specimen_quantity.point }
      context "divide_flg true" do
        let(:divide_flg) { true }
        it do
          expect(subject.class).to eq(Hash)
          expect(subject[:id]).to eq(divide.id)
          expect(subject[:x]).to eq(divide.chart_updated_at)
          expect(subject[:y]).to eq(100000.0)
          expect(subject[:date_str]).to eq("2016/11/12 00:00:00")
          expect(subject[:quantity_str]).to eq("100.0 kg")
          expect(subject[:before_specimen_name]).to eq(before_specimen.name)
          expect(subject[:comment]).to eq("log")
        end
      end
      context "divide_flg false" do
        let(:divide_flg) { false }
        it do
          expect(subject.class).to eq(Hash)
          expect(subject[:id]).to eq(divide.id)
          expect(subject[:x]).to eq(divide.chart_updated_at)
          expect(subject[:y]).to eq(100000.0)
          expect(subject[:date_str]).to eq("2016/11/12 00:00:00")
          expect(subject[:quantity_str]).to eq("100.0 kg")
          expect(subject[:before_specimen_name]).to be_nil
          expect(subject[:comment]).to eq("log")
        end
      end
    end
  end
end
