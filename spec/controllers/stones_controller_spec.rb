require 'spec_helper'
include ActionDispatch::TestProcess

describe StonesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:stone_1) { FactoryGirl.create(:stone, name: "hoge") }
    let(:stone_2) { FactoryGirl.create(:stone, name: "stone_2") }
    let(:stone_3) { FactoryGirl.create(:stone, name: "stone_3") }
    before do
      stone_1;stone_2;stone_3
      get :index
    end
    it { expect(assigns(:stones).count).to eq 3 }
  end

  describe "POST upload" do
    let(:obj){FactoryGirl.create(:stone) }
    let(:data) {fixture_file_upload("/files/test_image.jpg",'image/jpeg') }
    it { expect {post :upload, id: obj.id  ,data: data}.to change(AttachmentFile, :count).by(1) }
    context "" do
      before{post :upload, id: obj.id  ,data: data}
      it{expect(assigns(:stone).attachment_files.last.data_file_name).to eq "test_image.jpg"}
    end
  end

end
