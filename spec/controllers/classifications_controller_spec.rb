require 'spec_helper'

describe ClassificationsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:classification_1) { FactoryGirl.create(:classification, name: "hoge") }
    let(:classification_2) { FactoryGirl.create(:classification, name: "classification_2") }
    let(:classification_3) { FactoryGirl.create(:classification, name: "classification_3") }
    let(:classifications){ Classification.all }
    before do
      classification_1;classification_2;classification_3
      get :index
    end
    it { expect(assigns(:classifications).size).to eq classifications.size }
  end

  # This "GET show" has no html.
  describe "GET show" do
    let(:classification) { FactoryGirl.create(:classification) }
    before do
      classification
      get :show, id: classification.id, format: :json
    end
    it { expect(response.body).to eq(classification.to_json) }
  end

  describe "GET edit" do
    let(:classification) { FactoryGirl.create(:classification) }
    before do
      classification
      get :edit, id: classification.id
    end
    it { expect(assigns(:classification)).to eq classification }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "classification_name", description: "new descripton"} }
      it { expect { post :create, classification: attributes }.to change(Classification, :count).by(1) }
      context "assigns a newly created classification as @classification" do
        before {post :create, classification: attributes}
        it{expect(assigns(:classification)).to be_persisted}
        it{expect(assigns(:classification).name).to eq(attributes[:name])}
        it{expect(assigns(:classification).description).to eq(attributes[:description])}
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow_any_instance_of(Classification).to receive(:save).and_return(false) }
      it { expect { post :create, classification: attributes }.not_to change(Classification, :count) }
      context "assigns a newly but unsaved classification as @classification" do
        before {post :create, classification: attributes}
        it{expect(assigns(:classification)).to be_new_record}
        it{expect(assigns(:classification).name).to eq(attributes[:name])}
        it{expect(assigns(:classification).description).to eq(attributes[:description])}
      end
    end
  end

  describe "PUT update" do
    let(:classification) { FactoryGirl.create(:classification, name: "classification", description: "description") }
    before do
      classification
      put :update, id: classification.id, classification: attributes
    end
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name",description: "update description"} }
      it { expect(assigns(:classification)).to eq classification }
      it { expect(assigns(:classification).name).to eq attributes[:name] }
      it { expect(assigns(:classification).description).to eq attributes[:description] }
      it { expect(response).to redirect_to(classifications_path) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: "",description: "update description"} }
      before { allow(classification).to receive(:update_attributes).and_return(false) }
      it { expect(assigns(:classification)).to eq classification }
      it { expect(assigns(:classification).name).to eq attributes[:name] }
      it { expect(assigns(:classification).description).to eq attributes[:description] }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    let(:classification) { FactoryGirl.create(:classification, name: "classification", description: "description") }
    before{ classification }
    it { expect { delete :destroy,id: classification.id }.to change(Classification, :count).by(-1) }
  end
end
