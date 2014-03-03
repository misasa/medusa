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
    it { expect(assigns(:bibs).count).to eq 3 }
  end

  describe "POST upload" do
    let(:obj){FactoryGirl.create(:bib) }
    let(:media) {fixture_file_upload("/files/test_image.jpg",'image/jpeg') }
    it { expect {post :upload, id: obj.id  ,media: media}.to change(AttachmentFile, :count).by(1) }
    context "" do
      before{post :upload, id: obj.id  ,media: media}
      it{expect(assigns(:bib).attachment_files.last.data_file_name).to eq "test_image.jpg"}
    end
  end

end
