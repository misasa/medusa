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
  end

  describe "PUT update" do
    let!(:specimen) { FactoryGirl.create(:specimen) }
    let!(:physical_form) { FactoryGirl.create(:physical_form) }
    let(:attributes) do
      {
        quantity: 100,
        quantity_unit: "kg",
        children_attributes: [
          { name: "child_1",physical_form_id: physical_form.id, quantity: 60, quantity_unit: "kg" },
          { name: "child_2",physical_form_id: physical_form.id, quantity: 40, quantity_unit: "kg" }
        ]
      }
    end
    subject { put :update, id: specimen.id, specimen:attributes }
    context "witout format" do
      before { subject }
      it { expect(assigns(:specimen)).to eq specimen }
      it { expect(assigns(:specimen).quantity).to eq attributes[:quantity] }
      it { expect(assigns(:specimen).quantity_unit).to eq attributes[:quantity_unit] }
    end
    it { expect{ subject }.to change{ Specimen.find(specimen.id).children.size }.from(0).to(2) }
  end

  describe "PUT loss" do
    let!(:specimen) { FactoryGirl.create(:specimen, quantity: 200, quantity_unit: "kg") }
    let!(:physical_form) { FactoryGirl.create(:physical_form) }
    let(:attributes) do
      {
        quantity: 100,
        quantity_unit: "kg",
        children_attributes: [
          { name: "child_1",physical_form_id: physical_form.id, quantity: 50, quantity_unit: "kg" },
          { name: "child_2",physical_form_id: physical_form.id, quantity: 40, quantity_unit: "kg" }
        ]
      }
    end
    subject { put :loss, id: specimen.id, specimen:attributes }
    context "witout format" do
      before { subject }
      it do
        json = JSON.parse(response.body)
        expect(json["loss"]).to eq("10,000.0(g)")
      end
    end
  end
end
