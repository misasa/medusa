require 'spec_helper'

describe UnitsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  
  describe "GET index" do
    let(:unit_1) { FactoryGirl.create(:unit, name: "hoge") }
    let(:unit_2) { FactoryGirl.create(:unit, name: "unit_2") }
    let(:unit_3) { FactoryGirl.create(:unit, name: "unit_3") }
    let(:params) { {q: query, page: 2, per_page: 1} }
    before do
      unit_1;unit_2;unit_3
      get :index, params
    end
    context "sort condition is present" do
      let(:query) { {"name_cont" => "unit", "s" => "updated_at DESC"} }
      it { expect(assigns(:units)).to eq [unit_2] }
    end
    context "sort condition is nil" do
      let(:query) { {"name_cont" => "unit"} }
      it { expect(assigns(:units)).to eq [unit_3] }
    end
  end
  
  # This "GET show" has no html.
  describe "GET show" do
    let(:unit) { FactoryGirl.create(:unit) }
    before do
      unit
      get :show, id: unit.id, format: :json
    end
    it { expect(response.body).to eq(unit.to_json) }
  end
  
  describe "GET edit" do
    let(:unit) { FactoryGirl.create(:unit) }
    before do
      unit
      get :edit, id: unit.id
    end
    it { expect(assigns(:unit)).to eq unit }
  end
  
  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "unit_name"} }
      it { expect { post :create, unit: attributes }.to change(Unit, :count).by(1) }
      it "assigns a newly created unit as @unit" do
        post :create, unit: attributes
        expect(assigns(:unit)).to be_persisted
        expect(assigns(:unit).name).to eq(attributes[:name])
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow_any_instance_of(Unit).to receive(:save).and_return(false) }
      it { expect { post :create, unit: attributes }.not_to change(Unit, :count) }
      it "assigns a newly but unsaved unit as @unit" do
        post :create, unit: attributes
        expect(assigns(:unit)).to be_new_record
        expect(assigns(:unit).name).to eq(attributes[:name])
      end
    end
  end
  
  describe "PUT update" do
    let(:unit) { FactoryGirl.create(:unit, name: "unit") }
    before do
      unit
      put :update, id: unit.id, unit: attributes
    end
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name"} }
      it { expect(assigns(:unit)).to eq unit }
      it { expect(assigns(:unit).name).to eq attributes[:name] }
      it { expect(response).to redirect_to(units_path) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow(unit).to receive(:update_attributes).and_return(false) }
      it { expect(assigns(:unit)).to eq unit }
      it { expect(assigns(:unit).name).to eq attributes[:name] }
      it { expect(response).to render_template("edit") }
    end
  end
  
end
