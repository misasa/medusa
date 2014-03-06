require 'spec_helper'
include ActionDispatch::TestProcess

describe BibsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:bib_1) { FactoryGirl.create(:bib, name: "hoge") }
    let(:bib_2) { FactoryGirl.create(:bib, name: "bib_2") }
    let(:bib_3) { FactoryGirl.create(:bib, name: "bib_3") }
    before do
      bib_1;bib_2;bib_3
      get :index
    end
    it { expect(assigns(:search).class).to eq Ransack::Search }
    it { expect(assigns(:bibs).count).to eq 3 }
  end
  
  describe "GET show" do
    let(:bib) { FactoryGirl.create(:bib) }
    before { get :show, id: bib.id }
    it{ expect(assigns(:bib)).to eq bib }
  end
  
  describe "GET edit" do
    let(:bib) { FactoryGirl.create(:bib) }
    before { get :edit, id: bib.id }
    it{ expect(assigns(:bib)).to eq bib }
  end
  
  describe "POST create" do
    let(:attributes) { {name: "bib_name"} }
    it { expect { post :create, bib: attributes }.to change(Bib, :count).by(1) }
    describe "assigns as @bib" do
      before{ post :create, bib: attributes }
      it{ expect(assigns(:bib)).to be_persisted }
      it { expect(assigns(:bib).name).to eq attributes[:name] }
    end
  end
  
  describe "PUT update" do
    before do
      bib
      put :update, id: bib.id, bib: attributes
    end
    let(:bib) { FactoryGirl.create(:bib) }
    let(:attributes) { {name: "update_name"} }
    it { expect(assigns(:bib)).to eq bib }
    it { expect(assigns(:bib).name).to eq attributes[:name] }
  end
  
  describe "DELETE destroy" do
    let(:bib) { FactoryGirl.create(:bib) }
    before { bib }
    it { expect { delete :destroy, id: bib.id }.to change(Bib, :count).by(-1) }
  end

  describe "POST upload" do
    let(:bib) { FactoryGirl.create(:bib) }
    let(:data) { fixture_file_upload("/files/test_image.jpg",'image/jpeg') }
    it { expect { post :upload, id: bib.id  ,data: data}.to change(AttachmentFile, :count).by(1) }
    describe "assigns @bib.attachment_files" do
      before { post :upload, id: bib.id  ,data: data }
      it{expect(assigns(:bib).attachment_files.last.data_file_name).to eq "test_image.jpg"}
    end
  end
  
  describe "GET property" do
    let(:bib) { FactoryGirl.create(:bib) }
    before { get :property, id: bib.id }
    it { expect(assigns(:bib)).to eq bib }
  end

end
