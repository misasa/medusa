require 'spec_helper'

describe NestedResources::BibsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "POST create" do
    let(:parent) { FactoryGirl.create(:attachment_file) }
    let(:attributes) { {name: "bib_name"} }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
    end
    it { expect {post :create, parent_resource: :attachment_file, attachment_file_id: parent, bib: attributes}.to change(Bib, :count).by(1) }
    context "parent attachment_file" do
      before { post :create, parent_resource: :attachment_file, attachment_file_id: parent, bib: attributes }
      it { expect(parent.bibs.last.name).to eq attributes[:name]}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe "DELETE destory" do
    let(:parent){FactoryGirl.create(:place) }
    let(:child){FactoryGirl.create(:bib)}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent
      child
    end
    it  {expect {delete :destroy, parent_resource: :place, place_id: parent,id: child.id}.to change(Bib, :count).by(0)}
    context "parent place" do
      before do
        parent.bibs << child
        delete :destroy, parent_resource: :place, place_id: parent, id: child.id
      end
      it {expect(parent.bibs.count).to eq 0}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe "POST link_by_global_id" do
    let(:parent){FactoryGirl.create(:attachment_file) }
    let(:child){FactoryGirl.create(:bib) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      child.record_property.global_id = "test_global_id"
      child.record_property.save
      post :link_by_global_id, parent_resource: :attachment_file, attachment_file_id: parent.id, global_id: child.global_id
    end
    it { expect(parent.bibs[0]).to eq(child)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
  end

end
