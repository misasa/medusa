require 'spec_helper'

describe NestedResources::AttachmentFilesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "POST create" do
    let(:parent){FactoryGirl.create(:place)}
    let(:attributes){{name: "attachment_file_name"}}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
    end
    it {expect {post :create, parent_resource: :place, place_id: parent, attachment_file: attributes}.to change(AttachmentFile, :count).by(1)}
    context "parent place" do
      let(:parent){FactoryGirl.create(:place)}
      before{post :create, parent_resource: :place, place_id: parent, attachment_file: attributes}
      it {expect(parent.attachment_files.last.name).to eq attributes[:name]}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe "DELETE destory" do
    let(:parent){FactoryGirl.create(:place) }
    let(:child){FactoryGirl.create(:attachment_file)}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent
      child
    end
    it  {expect {delete :destroy, parent_resource: :place, place_id: parent,id: child.id}.to change(AttachmentFile, :count).by(0)}
    context "parent place" do
      before do
        parent.attachment_files << child
        delete :destroy, parent_resource: :place, place_id: parent, id: child.id
      end
      it {expect(parent.attachment_files.count).to eq 0}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

end
