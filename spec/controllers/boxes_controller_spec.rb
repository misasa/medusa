require 'spec_helper'
include ActionDispatch::TestProcess

describe BoxesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:box_1) { FactoryGirl.create(:box, name: "hoge") }
    let(:box_2) { FactoryGirl.create(:box, name: "box_2") }
    let(:box_3) { FactoryGirl.create(:box, name: "box_3") }
    before do
      box_1;box_2;box_3
      get :index
    end
    it { expect(assigns(:search).class).to eq Ransack::Search }
    it { expect(assigns(:boxes).count).to eq 3 }
  end

  describe "GET show" do
    let(:box) { FactoryGirl.create(:box) }
    before { get :show, id: box.id }
    it { expect(assigns(:box)).to eq box }
  end

  describe "GET edit" do
    let(:box) { FactoryGirl.create(:box) }
    before { get :edit, id: box.id }
    it { expect(assigns(:box)).to eq box }
  end

  describe "POST create" do
    let(:attributes) { {name: "box_name"} }
    it { expect { post :create, box: attributes }.to change(Box, :count).by(1) }
    describe "assigns as @box" do
      before { post :create, box: attributes }
      it { expect(assigns(:box)).to be_persisted }
      it { expect(assigns(:box).name).to eq attributes[:name]}
    end
  end

  describe "PUT update" do
    before do
      box
      put :update, id: box.id, box: attributes
    end
    let(:box) { FactoryGirl.create(:box) }
    let(:attributes) { {name: "update_name"} }
    it { expect(assigns(:box)).to eq box }
    it { expect(assigns(:box).name).to eq attributes[:name] }
  end

  describe "DELETE destroy" do
    let(:box) { FactoryGirl.create(:box) }
    before { box }
    it { expect { delete :destroy, id: box.id }.to change(Box, :count).by(-1) }
  end

  describe "POST upload" do
    let(:box) { FactoryGirl.create(:box) }
    let(:media) { fixture_file_upload("/files/test_image.jpg", 'image/jpeg') }
    it { expect { post :upload, id: box.id, media: media }.to change(AttachmentFile, :count).by(1) }
    describe "assigns @box.attachment_files" do
      before { post :upload, id: box.id, media: media }
      it { expect(assigns(:box).attachment_files.last.data_file_name).to eq "test_image.jpg" }
    end
  end

  describe "GET family" do
    let(:box) { FactoryGirl.create(:box) }
    before { get :family, id: box.id }
    it { expect(assigns(:box)).to eq box }
  end

  describe "GET picture" do
    let(:box) { FactoryGirl.create(:box) }
    before { get :picture, id: box.id }
    it { expect(assigns(:box)).to eq box }
  end

  describe "GET property" do
    let(:box) { FactoryGirl.create(:box) }
    before { get :property, id: box.id }
    it { expect(assigns(:box)).to eq box }
  end

end
