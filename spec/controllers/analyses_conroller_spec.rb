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
    let(:media) {fixture_file_upload("/files/test_image.jpg",'image/jpeg') }
    it { expect {post :upload, id: obj.id  ,media: media}.to change(AttachmentFile, :count).by(1) }
    context "" do
      before{post :upload, id: obj.id  ,media: media}
      it{expect(assigns(:analysis).attachment_files.last.data_file_name).to eq "test_image.jpg"}
    end
  end

end
