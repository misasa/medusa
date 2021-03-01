require 'spec_helper'

describe Divide do

  describe "scope" do
    describe "default_scope" do
      let(:time) { Time.zone.local(2016, 11,12) }
      let!(:divide1) { FactoryBot.create(:divide, updated_at: time + 1.day) }
      let!(:divide2) { FactoryBot.create(:divide, updated_at: time) }
      subject { Divide.all }
      it { expect(subject).to eq([divide2, divide1]) }
    end

    describe "specimen_id_is" do
      let!(:divide1) { FactoryBot.create(:divide, before_specimen_quantity: specimen_quantity1) }
      let!(:divide2) { FactoryBot.create(:divide, before_specimen_quantity: specimen_quantity2) }
      let!(:specimen_quantity1) { FactoryBot.create(:specimen_quantity, specimen: specimen1) }
      let!(:specimen_quantity2) { FactoryBot.create(:specimen_quantity, specimen: specimen2) }
      let!(:specimen1) { FactoryBot.create(:specimen) }
      let!(:specimen2) { FactoryBot.create(:specimen) }
      subject { Divide.specimen_id_is(specimen1.id) }
      it { expect(subject).to eq([divide1]) }
    end
  end

  describe "before_specimen" do
    let(:divide) { FactoryBot.create(:divide, before_specimen_quantity: specimen_quantity) }
    let(:specimen_quantity) { FactoryBot.create(:specimen_quantity, specimen: specimen) }
    let(:specimen) { FactoryBot.create(:specimen) }
    subject { divide.before_specimen }
    context "exist before_specimen_quantity" do
      it { expect(subject).to eq(specimen) }
    end
    context "not exist before_specimen_quantity" do
      let(:specimen_quantity) { nil }
      it { expect(subject).to be_nil }
    end
  end

  describe "chart_updated_at" do
    let(:time) { Time.zone.local(2016, 11,12) }
    let(:divide) { FactoryBot.create(:divide, updated_at: time) }
    subject { divide.chart_updated_at }
    it { expect(subject).to eq(1478908800000) }
  end

  describe "updated_at_str" do
    let(:time) { Time.zone.local(2016, 11,12, 13, 14, 15) }
    let(:divide) { FactoryBot.create(:divide, updated_at: time) }
    subject { divide.updated_at_str }
    it { expect(subject).to eq("2016/11/12 13:14:15") }
  end

  describe "modify updated_at" do
    let(:time) { Time.zone.local(2016, 11,12, 13, 14, 15) }

    let(:divide) { FactoryBot.create(:divide, updated_at: time) }
    subject { divide.updated_at_str }
    before do
      divide.updated_at = "2015/11/12 13:14:15"
      divide.save
    end
    it { expect(subject).to eq("2015/11/12 13:14:15") }
  end

end
