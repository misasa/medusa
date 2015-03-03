require 'spec_helper'
include ActionDispatch::TestProcess

describe NestedResources::AttachmentFilesController do
  let(:parent_name){:bib}
  let(:child_name){:attachment_file}
  let(:parent) { FactoryGirl.create(parent_name) }
  let(:child) { FactoryGirl.create(child_name) }
  let(:user) { FactoryGirl.create(:user) }
  let(:url){"where_i_came_from"}
  let(:attributes) { {data: data} }
  let(:data){fixture_file_upload("/files/test_image.jpg",'image/jpeg')}
  before { request.env["HTTP_REFERER"]  = url }
  before { sign_in user }
  before { parent }
  before { child }

  describe "GET index", :current => true do
    subject { method }
    context "with format json" do
      let(:method){get :index, parent_resource: parent_name, bib_id: parent, association_name: :attachment_files, format: 'json'}
      before { 
        parent.attachment_files << child
        subject
      }
      it { expect(response.body).to include("\"original_path\":") }
      it { expect(response.body).to include("\"thumbnail_path\":") }
      it { expect(response.body).to include("\"tiny_path\":") }

    end
  end

  describe "POST create" do
    let(:method){post :create, parent_resource: parent_name, bib_id: parent, attachment_file: attributes}
    before{child}
    it { expect{method}.to change(AttachmentFile, :count).by(1) }
    context "validate" do
      before { method }
      it { expect(parent.attachment_files.exists?(data_file_name: "test_image.jpg")).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "invalidate" do
      let(:data){nil}
      before { method }
      it { expect {method}.to change(AttachmentFile, :count).by(0) }
      it { expect(parent.attachment_files.exists?(data_file_name: "test_image.jpg")).to eq false}
      it { expect(response).to render_template("error")}
    end
  end

  describe "PUT update" do
    let(:method){put :update, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :attachment_files}
    let(:child_id){child.id}
    it { expect {method}.to change(Analysis, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(assigns(child_name)).to eq child }
      it { expect(parent.attachment_files.exists?(id: child.id)).to eq true}
    end
    context "none child" do
      let(:child_id){0}
      it { expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "DELETE destory" do
    let(:method){delete :destroy, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :attachment_files}
    before { parent.attachment_files << child}
    let(:child_id){child.id}
    it { expect {method}.to change(Analysis, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(parent.attachment_files.exists?(id: child.id)).to eq false}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "none child" do
      let(:child_id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "POST link_by_global_id" do
    let(:method){post :link_by_global_id, parent_resource: parent_name,bib_id: parent.id, global_id: global_id }
    context "present child" do
      let(:global_id){child.global_id}
      before { method }
      it { expect(parent.attachment_files.exists?(id: child.id)).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "none child" do
      let(:global_id){"aaaa"}
      before { method }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "occur raise" do
      before { allow(AttachmentFile).to receive(:joins).and_raise }
      context "format html" do
        before do
          post :link_by_global_id, parent_resource: parent_name.to_s, bib_id: parent.id, global_id: child.global_id, format: :html
        end
        it { expect(response.body).to render_template("parts/duplicate_global_id") }
        it { expect(response.status).to eq 422 }
      end
      context "format json" do
        before do
          post :link_by_global_id, parent_resource: parent_name.to_s, bib_id: parent.id, global_id: child.global_id, format: :json
        end
        it { expect(response.body).to be_blank }
        it { expect(response.status).to eq 422 }
      end
    end
  end

end
