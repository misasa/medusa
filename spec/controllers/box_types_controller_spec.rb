require 'spec_helper'

describe BoxTypesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:box_type_1) { FactoryGirl.create(:box_type, name: "hoge") }
    let(:box_type_2) { FactoryGirl.create(:box_type, name: "box_type_2") }
    let(:box_type_3) { FactoryGirl.create(:box_type, name: "box_type_3") }
    let(:box_types){ BoxType.all }
    before do
      box_type_1;box_type_2;box_type_3
      get :index
    end
    it { expect(assigns(:box_types).size).to eq box_types.size }
  end

  # This "GET show" has no html.
  describe "GET show" do
    let(:box_type) { FactoryGirl.create(:box_type) }
    before do
      box_type
      get :show, id: box_type.id, format: :json
    end
    it { expect(response.body).to eq(box_type.to_json) }
  end

  describe "GET edit" do
    let(:box_type) { FactoryGirl.create(:box_type) }
    before do
      box_type
      get :edit, id: box_type.id
    end
    it { expect(assigns(:box_type)).to eq box_type }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "box_type_name", description: "new descripton"} }
      it { expect { post :create, box_type: attributes }.to change(BoxType, :count).by(1) }
      context "assigns a newly created box_type as @box_type" do
        before {post :create, box_type: attributes}
        it{expect(assigns(:box_type)).to be_persisted}
        it{expect(assigns(:box_type).name).to eq(attributes[:name])}
        it{expect(assigns(:box_type).description).to eq(attributes[:description])}
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow_any_instance_of(BoxType).to receive(:save).and_return(false) }
      it { expect { post :create, box_type: attributes }.not_to change(BoxType, :count) }
      context "assigns a newly but unsaved box_type as @box_type" do
        before {post :create, box_type: attributes}
        it{expect(assigns(:box_type)).to be_new_record}
        it{expect(assigns(:box_type).name).to eq(attributes[:name])}
        it{expect(assigns(:box_type).description).to eq(attributes[:description])}
      end
    end
  end

  describe "PUT update" do
    let(:box_type) { FactoryGirl.create(:box_type, name: "box_type", description: "description") }
    before do
      box_type
      put :update, id: box_type.id, box_type: attributes
    end
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name",description: "update description"} }
      it { expect(assigns(:box_type)).to eq box_type }
      it { expect(assigns(:box_type).name).to eq attributes[:name] }
      it { expect(assigns(:box_type).description).to eq attributes[:description] }
      it { expect(response).to redirect_to(box_types_path) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: "",description: "update description"} }
      before { allow(box_type).to receive(:update_attributes).and_return(false) }
      it { expect(assigns(:box_type)).to eq box_type }
      it { expect(assigns(:box_type).name).to eq attributes[:name] }
      it { expect(assigns(:box_type).description).to eq attributes[:description] }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    let(:box_type) { FactoryGirl.create(:box_type, name: "box_type", description: "description") }
    before{ box_type }
    it { expect { delete :destroy,id: box_type.id }.to change(BoxType, :count).by(-1) }
  end
end
