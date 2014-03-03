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

  describe "POST upload" do
    let(:obj){FactoryGirl.create(:place) }
    let(:media) {fixture_file_upload("/files/test_image.jpg",'image/jpeg') }
    it { expect {post :upload, id: obj.id  ,media: media}.to change(AttachmentFile, :count).by(1) }
    context "" do
      before{post :upload, id: obj.id  ,media: media}
      it{expect(assigns(:place).attachment_files.last.data_file_name).to eq "test_image.jpg"}
    end
  end

end
