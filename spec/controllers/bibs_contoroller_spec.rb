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
  
  describe "POST link_stone_by_global_id" do
    let(:bib) { FactoryGirl.create(:bib) }
    let(:stone) { FactoryGirl.create(:stone) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      stone.record_property.global_id = "test_global_id"
      stone.record_property.save
      post :link_stone_by_global_id, id: bib.id, global_id: stone.global_id
    end
    it { expect(bib.stones[0]).to eq(stone)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
  end
  
  describe "POST link_box_by_global_id" do
    let(:bib) { FactoryGirl.create(:bib) }
    let(:box) { FactoryGirl.create(:box) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      box.record_property.global_id = "test_global_id"
      box.record_property.save
      post :link_box_by_global_id, id: bib.id, global_id: box.global_id
    end
    it { expect(bib.boxes[0]).to eq(box)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
  end
  
  describe "POST link_place_by_global_id" do
    let(:bib) { FactoryGirl.create(:bib) }
    let(:place) { FactoryGirl.create(:place) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      place.record_property.global_id = "test_global_id"
      place.record_property.save
      post :link_place_by_global_id, id: bib.id, global_id: place.global_id
    end
    it { expect(bib.places[0]).to eq(place)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
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

  describe "POST bundle_edit" do
    let(:obj1) { FactoryGirl.create(:bib, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:bib, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:bib, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, ids: ids
    end
    it {expect(assigns(:bibs).include?(obj1)).to be_truthy}
    it {expect(assigns(:bibs).include?(obj2)).to be_truthy}
    it {expect(assigns(:bibs).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3name){"obj3"}
    let(:obj1) { FactoryGirl.create(:bib, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:bib, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:bib, name: obj3name) }
    let(:attributes) { {name: "update_name"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, ids: ids,bib: attributes
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.name).to eq attributes[:name]}
    it {expect(obj2.name).to eq attributes[:name]}
    it {expect(obj3.name).to eq obj3name}
  end

end
