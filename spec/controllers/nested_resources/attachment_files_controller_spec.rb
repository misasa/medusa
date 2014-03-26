require 'spec_helper'
include ActionDispatch::TestProcess

describe NestedResources::AttachmentFilesController do
  let(:parent) { FactoryGirl.create(:bib) }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "POST create" do
    let(:attributes){{data: data}}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
    end
    context "validate" do
      let(:data){fixture_file_upload("/files/test_image.jpg",'image/jpeg')}
      it { expect {post :create, parent_resource: :bib, bib_id: parent, attachment_file: attributes}.to change(AttachmentFile, :count).by(1) }
      context "parent bib" do
        before { post :create, parent_resource: :bib, bib_id: parent, attachment_file: attributes }
        it { expect(parent.attachment_files.last.data_file_name).to eq "test_image.jpg"}
        it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
      end
    end
    context "invalidate" do
      let(:data) {nil}
      it { expect {post :create, parent_resource: :bib, bib_id: parent, attachment_file: attributes}.to change(AttachmentFile, :count).by(0) }
      context "parent bib" do
        before { post :create, parent_resource: :bib, bib_id: parent, attachment_file: attributes }
        it { expect(response).to render_template("error")}
      end
    end
  end

  describe "DELETE destory" do
    let(:child){FactoryGirl.create(:attachment_file)}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent
      child
    end
    it  {expect {delete :destroy, parent_resource: :bib, bib_id: parent,id: child.id}.to change(AttachmentFile, :count).by(0)}
    context "parent bib" do
      before do
        parent.attachment_files << child
        delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id
      end
      it {expect(parent.attachment_files.count).to eq 0}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe "POST link_by_global_id" do
    let(:child){FactoryGirl.create(:attachment_file) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      child.record_property.global_id = "test_global_id"
      child.record_property.save
      post :link_by_global_id, parent_resource: :bib, bib_id: parent.id, global_id: child.global_id
    end
    it { expect(parent.attachment_files[0]).to eq(child)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
  end

  describe ".add_tab_param" do
    let(:tabname){"analysis"}
    let(:child){FactoryGirl.create(:attachment_file) }
    let(:base_url){"http://wwww.test.co.jp/"}
    before do
      request.env["HTTP_REFERER"]  = url
      child.record_property.global_id = "test_global_id"
      child.record_property.save
      post :link_by_global_id, parent_resource: :bib, bib_id: parent.id, global_id: child.global_id, association_name: :attachment_file, tab: tab 
    end
    context "add none param" do
      let(:tab){""}
      let(:url){base_url}
      it { expect(response).to redirect_to base_url}
    end
    context "add param" do
      let(:tab){tabname}
      context "1st param" do
        let(:url){base_url}
        it { expect(response).to redirect_to base_url + "?tab=" + tabname}
      end
      context "2nd param" do
        let(:url){base_url + "?aaa=aaa"}
        it { expect(response).to redirect_to base_url + "?aaa=aaa&tab=" + tabname}
      end
      context "exsist tab param other param" do
        let(:url){base_url + "?tab=aaa&aaa=aaa"}
        it { expect(response).to redirect_to base_url + "?aaa=aaa&tab=" + tabname}
      end
      context "exsist tab param other none param" do
        let(:url){base_url + "?tab=aaa"}
        it { expect(response).to redirect_to base_url + "?tab=" + tabname}
      end
    end
  end

end
