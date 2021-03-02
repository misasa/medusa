require 'spec_helper'

describe CustomAttributesController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:custom_attribute_1) { FactoryBot.create(:custom_attribute, name: "hoge") }
    let(:custom_attribute_2) { FactoryBot.create(:custom_attribute, name: "custom_attribute_2") }
    let(:custom_attribute_3) { FactoryBot.create(:custom_attribute, name: "custom_attribute_3") }
    let(:params) { {q: query, page: 2, per_page: 1} }
    before do
      custom_attribute_1;custom_attribute_2;custom_attribute_3
      get :index, params: params
    end
    context "sort condition is present" do
      let(:query) { {"name_cont" => "custom_attribute", "s" => "updated_at DESC"} }
      it { expect(assigns(:custom_attributes)).to eq [custom_attribute_2] }
    end
    context "sort condition is nil" do
      let(:query) { {"name_cont" => "custom_attribute"} }
      it { expect(assigns(:custom_attributes)).to eq [custom_attribute_3] }
    end
  end

  # This "GET show" has no html.
  describe "GET show" do
    let(:custom_attribute) { FactoryBot.create(:custom_attribute) }
    before do
      custom_attribute
      get :show, params: { id: custom_attribute.id, format: :json }
    end
    it { expect(response.body).to eq(custom_attribute.to_json) }
  end

  describe "GET edit" do
    let(:custom_attribute) { FactoryBot.create(:custom_attribute) }
    before do
      custom_attribute
      get :edit, params: { id: custom_attribute.id }
    end
    it { expect(assigns(:custom_attribute)).to eq custom_attribute }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "custom_attribute_name"} }
      it { expect { post :create, params: { custom_attribute: attributes }}.to change(CustomAttribute, :count).by(1) }
      it "assigns a newly created custom_attribute as @custom_attribute" do
        post :create, params: { custom_attribute: attributes }
        expect(assigns(:custom_attribute)).to be_persisted
        expect(assigns(:custom_attribute).name).to eq(attributes[:name])
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow_any_instance_of(CustomAttribute).to receive(:save).and_return(false) }
      it { expect { post :create, params: { custom_attribute: attributes }}.not_to change(CustomAttribute, :count) }
      it "assigns a newly but unsaved custom_attribute as @custom_attribute" do
        post :create, params: { custom_attribute: attributes }
        expect(assigns(:custom_attribute)).to be_new_record
        expect(assigns(:custom_attribute).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:custom_attribute) { FactoryBot.create(:custom_attribute, name: "custom_attribute") }
    before do
      custom_attribute
      put :update, params: { id: custom_attribute.id, custom_attribute: attributes }
    end
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name"} }
      it { expect(assigns(:custom_attribute)).to eq custom_attribute }
      it { expect(assigns(:custom_attribute).name).to eq attributes[:name] }
      it { expect(response).to redirect_to(custom_attributes_path) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow(custom_attribute).to receive(:update).and_return(false) }
      it { expect(assigns(:custom_attribute)).to eq custom_attribute }
      it { expect(assigns(:custom_attribute).name).to eq attributes[:name] }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    let(:custom_attribute) { FactoryBot.create(:custom_attribute, name: "custom_attribute") }
    before { custom_attribute }
    it { expect { delete :destroy, params: { id: custom_attribute.id }}.to change(CustomAttribute, :count).by(-1) }
  end

end
