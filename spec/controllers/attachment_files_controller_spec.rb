require 'spec_helper'
include ActionDispatch::TestProcess

describe AttachmentFilesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:attachment_file_1) { FactoryGirl.create(:attachment_file, name: "hoge") }
    let(:attachment_file_2) { FactoryGirl.create(:attachment_file, name: "attachment_file_2") }
    let(:attachment_file_3) { FactoryGirl.create(:attachment_file, name: "attachment_file_3") }
    before do
      attachment_file_1;attachment_file_2;attachment_file_3
      get :index
    end
    it { expect(assigns(:attachment_files).count).to eq 3 }
  end

  describe "GET download" do
    after { get :download, id: attachment_file.id }
    let(:attachment_file) { FactoryGirl.create(:attachment_file) }
    before do
      attachment_file
      allow(controller).to receive(:send_file).and_return{controller.render :nothing => true}
    end
    it { expect(controller).to receive(:send_file).with("public" + attachment_file.path, filename: attachment_file.data_file_name, type: attachment_file.data_content_type) }
  end

  describe "POST link_stone_by_global_id" do
    let(:obj){FactoryGirl.create(:attachment_file) }
    let(:stone){FactoryGirl.create(:stone) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      stone.record_property.global_id = "test_global_id"
      stone.record_property.save
      post :link_stone_by_global_id,id:obj.id,global_id: stone.global_id
    end
    it { expect(obj.stones[0]).to eq(stone)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryGirl.create(:attachment_file, description: "obj1") }
    let(:obj2) { FactoryGirl.create(:attachment_file, description: "obj2") }
    let(:obj3) { FactoryGirl.create(:attachment_file, description: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, ids: ids
    end
    it {expect(assigns(:attachment_files).include?(obj1)).to be_truthy}
    it {expect(assigns(:attachment_files).include?(obj2)).to be_truthy}
    it {expect(assigns(:attachment_files).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3description){"obj3"}
    let(:obj1) { FactoryGirl.create(:attachment_file, description: "obj1") }
    let(:obj2) { FactoryGirl.create(:attachment_file, description: "obj2") }
    let(:obj3) { FactoryGirl.create(:attachment_file, description: obj3description) }
    let(:attributes) { {description: "update_description"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, ids: ids,attachment_file: attributes
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.description).to eq attributes[:description]}
    it {expect(obj2.description).to eq attributes[:description]}
    it {expect(obj3.description).to eq obj3description}
  end

end
