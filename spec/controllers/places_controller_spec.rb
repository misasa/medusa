require 'spec_helper'
include ActionDispatch::TestProcess

describe PlacesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:place_1) { FactoryGirl.create(:place, name: "hoge") }
    let(:place_2) { FactoryGirl.create(:place, name: "place_2") }
    let(:place_3) { FactoryGirl.create(:place, name: "place_3") }
    before do
      place_1;place_2;place_3
      get :index
    end
    it { expect(assigns(:places).count).to eq 3 }
  end

  describe "GET show" do
    let(:obj){FactoryGirl.create(:place) }
    before{get :show,id:obj.id}
    it{expect(assigns(:place)).to eq obj}
    it{expect(response).to render_template("show") }
  end

  describe "GET map" do
    let(:obj){FactoryGirl.create(:place) }
    before{get :map,id:obj.id}
    it{expect(assigns(:place)).to eq obj}
    it{expect(response).to render_template("map") }
  end

  describe "GET property" do
    let(:obj){FactoryGirl.create(:place) }
    before{get :property,id:obj.id}
    it{expect(assigns(:place)).to eq obj}
    it{expect(response).to render_template("property") }
  end

  describe "POST create" do
    let(:attributes) { {name: "place_name"} }
    it { expect {post :create ,place: attributes}.to change(Place, :count).by(1) }
    context "" do
      before{post :create ,place: attributes}
      it{expect(assigns(:place).name).to eq attributes[:name]}
    end
  end

  describe "PUT update" do
    let(:obj){FactoryGirl.create(:place) }
    let(:attributes) { {name: "update_name"} }
    it { expect {put :update ,id: obj.id,place: attributes}.to change(Place, :count).by(0) }
    before do
      obj
      put :update, id: obj.id, place: attributes
    end
    it{expect(assigns(:place).name).to eq attributes[:name]}
  end

  describe "POST upload" do
    let(:obj){FactoryGirl.create(:place) }
    let(:media) {fixture_file_upload("/files/test_image.jpg",'image/jpeg') }
    it { expect {post :upload, id: obj.id  ,media: media}.to change(AttachmentFile, :count).by(1) }
    context "" do
      before{post :upload, id: obj.id  ,media: media}
      it{expect(assigns(:place).attachment_files.last.data_file_name).to eq "test_image.jpg"}
    end
  end

  describe "DELETE destroy" do
    let(:obj){FactoryGirl.create(:place) }
    before { obj }
    it { expect { delete :destroy,id: obj.id }.to change(Place, :count).by(-1) }
  end

end
