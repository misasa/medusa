require 'spec_helper'
include ActionDispatch::TestProcess

describe AnalysesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:analysis_1) { FactoryGirl.create(:analysis, name: "hoge") }
    let(:analysis_2) { FactoryGirl.create(:analysis, name: "analysis_2") }
    let(:analysis_3) { FactoryGirl.create(:analysis, name: "analysis_3") }
    before do
      analysis_1;analysis_2;analysis_3
      get :index
    end
    it { expect(assigns(:analyses).count).to eq 3 }
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

end
