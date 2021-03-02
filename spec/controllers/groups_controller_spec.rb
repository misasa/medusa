require 'spec_helper'

describe GroupsController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:group_1) { FactoryBot.create(:group, name: "hoge") }
    let(:group_2) { FactoryBot.create(:group, name: "group_2") }
    let(:group_3) { FactoryBot.create(:group, name: "group_3") }
    let(:params) { {q: query, page: 2, per_page: 1} }
    before do
      group_1;group_2;group_3
      get :index, params: params
    end
    context "sort condition is present" do
      let(:query) { {"name_cont" => "group", "s" => "updated_at DESC"} }
      it { expect(assigns(:groups)).to eq [group_2] }
    end
    context "sort condition is nil" do
      let(:query) { {"name_cont" => "group"} }
      it { expect(assigns(:groups)).to eq [group_3] }
    end
  end

  # This "GET show" has no html.
  describe "GET show" do
    let(:group) { FactoryBot.create(:group) }
    before do
      group
      get :show, params: { id: group.id, format: :json }
    end
    it { expect(response.body).to eq(group.to_json) }
  end

  describe "GET edit" do
    let(:group) { FactoryBot.create(:group) }
    before do
      group
      get :edit, params: {id: group.id }
    end
    it { expect(assigns(:group)).to eq group }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "group_name"} }
      it { expect { post :create, params: { group: attributes }}.to change(Group, :count).by(1) }
      it "assigns a newly created group as @group" do
        post :create, params: { group: attributes }
        expect(assigns(:group)).to be_persisted
        expect(assigns(:group).name).to eq(attributes[:name])
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow_any_instance_of(Group).to receive(:save).and_return(false) }
      it { expect { post :create, params: { group: attributes }}.not_to change(Group, :count) }
      it "assigns a newly but unsaved group as @group" do
        post :create, params: { group: attributes }
        expect(assigns(:group)).to be_new_record
        expect(assigns(:group).name).to eq(attributes[:name])
      end
    end
  end

  describe "PUT update" do
    let(:group) { FactoryBot.create(:group, name: "group") }
    before do
      group
      put :update, params: { id: group.id, group: attributes }
    end
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name"} }
      it { expect(assigns(:group)).to eq group }
      it { expect(assigns(:group).name).to eq attributes[:name] }
      it { expect(response).to redirect_to(groups_path) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow(group).to receive(:update).and_return(false) }
      it { expect(assigns(:group)).to eq group }
      it { expect(assigns(:group).name).to eq attributes[:name] }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    let(:group) { FactoryBot.create(:group, name: "group") }
    before { group }
    it { expect { delete :destroy, params: { id: group.id }}.to change(Group, :count).by(-1) }
  end

end
