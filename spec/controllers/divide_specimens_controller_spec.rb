require 'spec_helper'
include ActionDispatch::TestProcess

describe DivideSpecimensController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET edit" do
    let(:specimen) { FactoryGirl.create(:specimen) }
    before { get :edit, id: specimen.id }
    it { expect(assigns(:specimen)).to eq(specimen) }
    it { expect(assigns(:specimen).children.first).to be_new_record }
    it { expect(assigns(:specimen).children.size).to eq(1) }
    it { expect(assigns(:divide).log).to eq "" }
  end

  describe "PUT update" do
    let!(:before_specimen) { FactoryGirl.create(:specimen) }
    let!(:specimen) { FactoryGirl.create(:specimen) }
    let!(:physical_form) { FactoryGirl.create(:physical_form) }
    let(:specimen_attributes) do
      {
        quantity: 100,
        quantity_unit: "kg",
        children_attributes: [
          { name: "child_1",physical_form_id: physical_form.id, quantity: 60, quantity_unit: "kg" },
          { name: "child_2",physical_form_id: physical_form.id, quantity: 40, quantity_unit: "kg" }
        ]
      }
    end
    let(:divide_attributes) do
      {
        log: "comment",
        divide_flg: true,
        before_specimen_quantity_id: before_specimen.specimen_quantities.last.id
      }
    end
    subject { put :update, id: specimen.id, specimen:specimen_attributes, divide: divide_attributes }
    context "witout format" do
      before { subject }
      it { expect(assigns(:specimen)).to eq specimen }
      it { expect(assigns(:specimen).quantity).to eq specimen_attributes[:quantity] }
      it { expect(assigns(:specimen).quantity_unit).to eq specimen_attributes[:quantity_unit] }
      it { expect(assigns(:divide).log).to eq divide_attributes[:log] }
    end
    it { expect{ subject }.to change{ Specimen.find(specimen.id).children.size }.from(0).to(2) }
    it { expect{ subject }.to change{ Divide.count }.by(1) }
  end

  describe "PUT loss" do
    let!(:before_specimen) { FactoryGirl.create(:specimen) }
    let!(:specimen) { FactoryGirl.create(:specimen, quantity: 200, quantity_unit: "kg") }
    let!(:physical_form) { FactoryGirl.create(:physical_form) }
    let(:specimen_attributes) do
      {
        quantity: 100,
        quantity_unit: "kg",
        children_attributes: [
          { name: "child_1",physical_form_id: physical_form.id, quantity: 50, quantity_unit: "kg" },
          { name: "child_2",physical_form_id: physical_form.id, quantity: 40, quantity_unit: "kg" }
        ]
      }
    end
    let(:divide_attributes) do
      {
        log: "comment",
        divide_flg: true,
        before_specimen_quantity_id: before_specimen.specimen_quantities.last
      }
    end
    subject { put :loss, id: specimen.id, specimen:specimen_attributes, divide: divide_attributes }
    context "witout format" do
      before { subject }
      it do
        json = JSON.parse(response.body)
        expect(json["loss"]).to eq("10,000.0(g)")
      end
    end
  end
end
