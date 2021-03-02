require 'spec_helper'

describe ClassificationsController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:classification_1) { FactoryBot.create(:classification, name: "hoge",  sesar_material: "Rock") }
    let(:classification_2) { FactoryBot.create(:classification, name: "classification_2",  sesar_material: "Rock") }
    let(:classification_3) { FactoryBot.create(:classification, name: "classification_3",  sesar_material: "Rock") }
    let(:classifications){ Classification.all }
    before do
      classification_1;classification_2;classification_3
      get :index
    end
    it { expect(assigns(:classifications).size).to eq classifications.size }
  end

  # This "GET show" has no html.
  describe "GET show" do
    let(:classification) { FactoryBot.create(:classification,  sesar_material: "Rock") }
    before do
      classification
      get :show, params: { id: classification.id, format: :json }
    end
    it { expect(response.body).to eq(classification.to_json) }
  end

  describe "GET edit" do
    let(:classification) { FactoryBot.create(:classification,  sesar_material: "Rock") }
    before do
      classification
      get :edit, params: { id: classification.id }
    end
    it { expect(assigns(:classification)).to eq classification }
    it { expect(assigns(:material)).to eq ["Biology","Gas","Ice","Liquid>aqueous","Liquid>organic","Mineral","Not applicable","Other","Particulate","Rock","Sedimen","Soil","Synthetic"] }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "classification_name", description: "new descripton", sesar_material: "Rock"} }
      it { expect { post :create, params: { classification: attributes }}.to change(Classification, :count).by(1) }
      context "assigns a newly created classification as @classification" do
        before {post :create, params: { classification: attributes }}
        it{expect(assigns(:classification)).to be_persisted}
        it{expect(assigns(:classification).name).to eq(attributes[:name])}
        it{expect(assigns(:classification).sesar_material).to eq(attributes[:sesar_material])}
        it{expect(assigns(:classification).description).to eq(attributes[:description])}
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow_any_instance_of(Classification).to receive(:save).and_return(false) }
      it { expect { post :create, params: { classification: attributes }}.not_to change(Classification, :count) }
      context "assigns a newly but unsaved classification as @classification" do
        before {post :create, params: { classification: attributes }}
        it{expect(assigns(:classification)).to be_new_record}
        it{expect(assigns(:classification).name).to eq(attributes[:name])}
        it{expect(assigns(:classification).description).to eq(attributes[:description])}
      end
    end
  end

  describe "PUT update" do
    let(:classification) { FactoryBot.create(:classification, name: "classification", description: "description", sesar_material: "Gas") }
    before do
      classification
      put :update, params: { id: classification.id, classification: attributes }
    end
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name",description: "update description", sesar_material: "Rock", sesar_classification: "Igneous"} }
      it { expect(assigns(:classification)).to eq classification }
      it { expect(assigns(:classification).name).to eq attributes[:name] }
      it { expect(assigns(:classification).description).to eq attributes[:description] }
      it { expect(assigns(:classification).sesar_material).to eq attributes[:sesar_material] }
      it { expect(assigns(:classification).sesar_classification).to eq attributes[:sesar_classification] }
      it { expect(response).to redirect_to(classifications_path) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: "",description: "update description"} }
      before { allow(classification).to receive(:update).and_return(false) }
      it { expect(assigns(:classification)).to eq classification }
      it { expect(assigns(:classification).name).to eq attributes[:name] }
      it { expect(assigns(:classification).description).to eq attributes[:description] }
      it { expect(response).to render_template("edit") }
    end
    describe "check_classification がfalse" do
      let(:attributes) { {name: "update_name",description: "update description", sesar_material: "Mineral", sesar_classification: "Igne"} }
      it { expect(assigns(:classification)).to eq classification }
      it { expect(assigns(:classification).name).to eq "classification" }
      it { expect(assigns(:classification).description).to eq "description" }
      it { expect(assigns(:classification).sesar_material).to eq "Gas" }
      it { expect(assigns(:classification).sesar_classification).to eq nil }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    let(:classification) { FactoryBot.create(:classification, name: "classification", sesar_material: "Rock", description: "description") }
    before{ classification }
    it { expect { delete :destroy, params: { id: classification.id }}.to change(Classification, :count).by(-1) }
  end

end
