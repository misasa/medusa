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
    it { expect(controller).to receive(:send_file).with(attachment_file.path, filename: attachment_file.data_file_name, type: attachment_file.data_content_type) }
  end

end
