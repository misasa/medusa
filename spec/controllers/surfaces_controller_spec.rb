require 'spec_helper'
include ActionDispatch::TestProcess

describe SurfacesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET 'index'" do
    let(:obj_1) { FactoryGirl.create(:surface, name: "hoge") }
    let(:obj_2) { FactoryGirl.create(:surface, name: "s_2") }
    let(:obj_3) { FactoryGirl.create(:surface, name: "s_3") }
    before do
      obj_1;obj_2;obj_3
      get :index
    end
    it { expect(assigns(:search).class).to eq Ransack::Search }
    it { expect(assigns(:surfaces).count).to eq 3 }
  end

  describe "GET 'show'" do
    let(:obj){FactoryGirl.create(:surface) }
    let(:image_1) { FactoryGirl.create(:attachment_file) }
    let(:image_2) { FactoryGirl.create(:attachment_file) }
    before do
      image_1;image_2;
      obj.images << image_1
      obj.images << image_2
    end
    context "without format" do    
      before{get :show,id:obj.id}
      it{expect(assigns(:surface)).to eq obj}
      it{expect(response).to render_template("show") }
    end

  end

  describe "GET edit" do
    let(:obj) { FactoryGirl.create(:surface) }
    before { get :edit, id: obj.id }
    it{ expect(assigns(:surface)).to eq obj }
  end
  
  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "surface_name"} }
      it { expect { post :create, surface: attributes }.to change(Surface, :count).by(1) }
      it "assigns a newly created surface as @surface" do
        post :create, surface: attributes
        expect(assigns(:surface)).to be_persisted
        expect(assigns(:surface).name).to eq(attributes[:name])
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow_any_instance_of(Surface).to receive(:save).and_return(false) }
      it { expect { post :create, surface: attributes }.not_to change(Surface, :count) }
      it "assigns a newly created surface as @surface" do
        post :create, surface: attributes
        expect(assigns(:surface)).to be_new_record
        expect(assigns(:surface).name).to eq(attributes[:name])
      end
    end
  end
  
  describe "PUT update" do
    before do
      obj
      put :update, id: obj.id, surface: attributes
    end
    let(:obj) { FactoryGirl.create(:surface) }
    let(:attributes) { {name: "update_name"} }
    it { expect(assigns(:surface)).to eq obj }
    it { expect(assigns(:surface).name).to eq attributes[:name] }
  end
  
  describe "DELETE destroy" do
    let(:obj) { FactoryGirl.create(:surface) }
    before { obj }
    it { expect { delete :destroy, id: obj.id }.to change(Surface, :count).by(-1) }
  end
  
  describe "GET property" do
    let(:obj) { FactoryGirl.create(:surface) }
    before { get :property, id: obj.id }
    it { expect(assigns(:surface)).to eq obj }
  end


end
