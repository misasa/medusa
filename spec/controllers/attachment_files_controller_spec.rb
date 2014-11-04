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
  
  describe "GET show" do
    let(:attachment_file) { FactoryGirl.create(:attachment_file) }
    before { get :show, id: attachment_file.id }
    it { expect(assigns(:attachment_file)).to eq attachment_file }
  end

  describe "GET show" do
    let(:attachment_file) { FactoryGirl.create(:attachment_file) }
    before { get :show, id: attachment_file.id, format: 'json' }
    it { expect(assigns(:attachment_file)).to eq attachment_file }
    it { expect(response.body).to include("\"global_id\":\"#{attachment_file.global_id}\"") }
  end
  
  describe "GET edit" do
    let(:attachment_file) { FactoryGirl.create(:attachment_file) }
    before { get :edit, id: attachment_file.id }
    it { expect(assigns(:attachment_file)).to eq attachment_file }
  end
  
  describe "POST create", :current => true do
    let(:md5hash){ Digest::MD5.hexdigest(File.open("spec/fixtures/files/test_image.jpg", 'rb').read) }    
    let(:attributes) { {data: fixture_file_upload("/files/test_image.jpg",'image/jpeg')} }
    it { expect { post :create, attachment_file: attributes, format: 'json' }.to change(AttachmentFile, :count).by(1) }
    describe "assigns as @attachment_file" do
      before { post :create, attachment_file: attributes, format: 'json' }
      it { expect(assigns(:attachment_file)).to be_persisted }
      it { expect(assigns(:attachment_file).md5hash).to eq md5hash}
    end
  end

  
  describe "PUT update" do
  end

  describe "GET property" do
    let(:attachment_file) { FactoryGirl.create(:attachment_file,name: "test") }
    before do
      attachment_file
      get :property,id: attachment_file.id
    end
    it {expect(assigns(:attachment_file)).to eq attachment_file}
  end

  describe "GET picture" do
    let(:attachment_file) { FactoryGirl.create(:attachment_file,name: "test") }
    before do
      attachment_file
      get :picture,id: attachment_file.id
    end
    it {expect(assigns(:attachment_file)).to eq attachment_file}
  end
  
  describe "DELETE destroy" do
  end

  describe "GET download" do
    after { get :download, id: attachment_file.id }
    let(:attachment_file) { FactoryGirl.create(:attachment_file) }
    before do
      attachment_file
      allow(controller).to receive(:send_file).and_return{controller.render :nothing => true}
    end
    it { expect(controller).to receive(:send_file).with(attachment_file.data.path, filename: attachment_file.data_file_name, type: attachment_file.data_content_type) }
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
