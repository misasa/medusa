require 'spec_helper'
include ActionDispatch::TestProcess

describe AnalysesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:obj_1) { FactoryGirl.create(:analysis, name: "hoge") }
    let(:obj_2) { FactoryGirl.create(:analysis, name: "analysis_2") }
    let(:obj_3) { FactoryGirl.create(:analysis, name: "analysis_3") }
    before do
      obj_1;obj_2;obj_3
      get :index
    end
    it { expect(assigns(:analyses).count).to eq 3 }
  end

  describe "GET show" do
    let(:obj) { FactoryGirl.create(:analysis) }
    before { get :show, id: obj.id }
    it{ expect(assigns(:analysis)).to eq obj }
  end

  describe "GET edit" do
    let(:obj) { FactoryGirl.create(:analysis) }
    before { get :edit, id: obj.id }
    it{ expect(assigns(:analysis)).to eq obj }
  end

  describe "POST create" do
    let(:attributes) { {name: "obj_name"} }
    it { expect { post :create, analysis: attributes }.to change(Analysis, :count).by(1) }
    describe "assigns as @analysis" do
      before{ post :create, analysis: attributes }
      it{ expect(assigns(:analysis)).to be_persisted }
      it { expect(assigns(:analysis).name).to eq attributes[:name] }
    end
  end

  describe "PUT update" do
    let(:obj) { FactoryGirl.create(:analysis) }
    let(:attributes) { {name: "update_name"} }
    before do
      put :update, id: obj.id, analysis: attributes
    end
    it { expect(assigns(:analysis)).to eq obj }
    it { expect(assigns(:analysis).name).to eq attributes[:name] }
  end

  describe "POST upload" do
    let(:obj){FactoryGirl.create(:analysis) }
    let(:data) {fixture_file_upload("/files/test_image.jpg",'image/jpeg') }
    it { expect {post :upload, id: obj.id  ,data: data}.to change(AttachmentFile, :count).by(1) }
    context "" do
      before{post :upload, id: obj.id  ,data: data}
      it{expect(assigns(:analysis).attachment_files.last.data_file_name).to eq "test_image.jpg"}
    end
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryGirl.create(:analysis, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:analysis, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:analysis, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, ids: ids
    end
    it {expect(assigns(:analyses).include?(obj1)).to be_truthy}
    it {expect(assigns(:analyses).include?(obj2)).to be_truthy}
    it {expect(assigns(:analyses).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3name){"obj3"}
    let(:obj1) { FactoryGirl.create(:analysis, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:analysis, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:analysis, name: obj3name) }
    let(:attributes) { {name: "update_name"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, ids: ids,analysis: attributes
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.name).to eq attributes[:name]}
    it {expect(obj2.name).to eq attributes[:name]}
    it {expect(obj3.name).to eq obj3name}
  end

  describe "GET picture" do
    let(:obj) { FactoryGirl.create(:analysis) }
    before { get :picture, id: obj.id }
    it { expect(assigns(:analysis)).to eq obj }
  end

  describe "GET property" do
    let(:obj) { FactoryGirl.create(:analysis) }
    before { get :property, id: obj.id }
    it { expect(assigns(:analysis)).to eq obj }
  end

end
