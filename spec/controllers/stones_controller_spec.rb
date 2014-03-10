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

  # send_data test returns unexpected object.
  pending "GET download_card" do
    after { get :download_card, id: stone.id }
    let(:stone) { FactoryGirl.create(:stone) }
    before do
      stone
      allow(stone).to receive(:build_card).and_return(double(:report))
      allow(double(:report)).to receive(:generate).and_return(double(:generate))
      allow(controller).to receive(:send_data).and_return{controller.render nothing: true}
    end
    it { expect(controller).to receive(:send_data).with(double(:generate), filename: "stone.pdf", type: "application/pdf") }
  end

  describe "GET download_bundle_card" do
    # send_data
  end

end
