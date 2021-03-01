require 'spec_helper'
include ActionDispatch::TestProcess

describe DivideSpecimensController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "PUT update" do
    let!(:specimen) { FactoryBot.create(:specimen) }
    let!(:physical_form) { FactoryBot.create(:physical_form) }
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
    subject { put :update, params: { id: specimen.id, specimen:attributes, format: :json }}
    context "witout format" do
      before { subject }
      it { expect(assigns(:specimen)).to eq specimen }
      it { expect(assigns(:specimen).quantity).to eq attributes[:quantity] }
      it { expect(assigns(:specimen).quantity_unit).to eq attributes[:quantity_unit] }
    end
    it { expect{ subject }.to change{ Specimen.find(specimen.id).children.size }.from(0).to(2) }
  end

  describe "PUT loss" do
    let!(:specimen) { FactoryBot.create(:specimen, quantity: 200, quantity_unit: "kg") }
    let!(:physical_form) { FactoryBot.create(:physical_form) }
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
    before { put :loss, params: params }
    subject { JSON.parse(response.body) }
    context "exists manual params" do
      let(:params) { { id: specimen.id, specimen:attributes, manual: "true" } }
      it { expect(subject["loss_quantity"]).to eq("10.0") }
      it { expect(subject["loss_quantity_unit"]).to eq("kg") }
      it { expect(subject["parent_quantity"]).to eq("100.0") }
      it { expect(subject["parent_quantity_unit"]).to eq("kg") }
    end
    context "not exists manual params" do
      let(:params) { { id: specimen.id, specimen:attributes } }
      it { expect(subject["loss_quantity"]).to eq("0.0") }
      it { expect(subject["loss_quantity_unit"]).to eq("g") }
      it { expect(subject["parent_quantity"]).to eq("110.0") }
      it { expect(subject["parent_quantity_unit"]).to eq("kg") }
    end
  end
end
