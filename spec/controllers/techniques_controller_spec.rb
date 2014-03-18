require 'spec_helper'

describe TechniquesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  
  describe "GET index" do
    let(:technique_1) { FactoryGirl.create(:technique, name: "hoge") }
    let(:technique_2) { FactoryGirl.create(:technique, name: "technique_2") }
    let(:technique_3) { FactoryGirl.create(:technique, name: "technique_3") }
    let(:params) { {q: query, page: 2, per_page: 1} }
    before do
      technique_1;technique_2;technique_3
      get :index, params
    end
    context "sort condition is present" do
      let(:query) { {"name_cont" => "technique", "s" => "updated_at DESC"} }
      it { expect(assigns(:techniques)).to eq [technique_2] }
    end
    context "sort condition is nil" do
      let(:query) { {"name_cont" => "technique"} }
      it { expect(assigns(:techniques)).to eq [technique_3] }
    end
  end
  
  # This "GET show" has no html.
  describe "GET show" do
    let(:technique) { FactoryGirl.create(:technique) }
    before do
      technique
      get :show, id: technique.id, format: :json
    end
    it { expect(response.body).to eq(technique.to_json) }
  end
  
  describe "GET edit" do
    let(:technique) { FactoryGirl.create(:technique) }
    before do
      technique
      get :edit, id: technique.id
    end
    it { expect(assigns(:technique)).to eq technique }
  end
  
  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "technique_name"} }
      it { expect { post :create, technique: attributes }.to change(Technique, :count).by(1) }
      it "assigns a newly created technique as @technique" do
        post :create, technique: attributes
        expect(assigns(:technique)).to be_persisted
        expect(assigns(:technique).name).to eq(attributes[:name])
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow_any_instance_of(Technique).to receive(:save).and_return(false) }
      it { expect { post :create, technique: attributes }.not_to change(Technique, :count) }
      it "assigns a newly but unsaved technique as @technique" do
        post :create, technique: attributes
        expect(assigns(:technique)).to be_new_record
        expect(assigns(:technique).name).to eq(attributes[:name])
      end
    end
  end
  
  describe "PUT update" do
    let(:technique) { FactoryGirl.create(:technique, name: "technique") }
    before do
      technique
      put :update, id: technique.id, technique: attributes
    end
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name"} }
      it { expect(assigns(:technique)).to eq technique }
      it { expect(assigns(:technique).name).to eq attributes[:name] }
      it { expect(response).to redirect_to(techniques_path) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow(technique).to receive(:update_attributes).and_return(false) }
      it { expect(assigns(:technique)).to eq technique }
      it { expect(assigns(:technique).name).to eq attributes[:name] }
      it { expect(response).to render_template("edit") }
    end
  end
  
  describe "DELETE destroy" do
    let(:technique) { FactoryGirl.create(:technique, name: "technique") }
    before { technique }
    it { expect { delete :destroy, id: technique.id }.to change(Technique, :count).by(-1) }
  end
  
end