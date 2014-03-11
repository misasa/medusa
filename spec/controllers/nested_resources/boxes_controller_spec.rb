require 'spec_helper'

describe NestedResources::BoxesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  
  describe "POST create" do
    let(:parent) { FactoryGirl.create(:bib) }
    let(:attributes) { {name: "box_name"} }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
    end
    it { expect {post :create, parent_resource: :bib, bib_id: parent, box: attributes}.to change(Box, :count).by(1) }
    context "parent box" do
      before { post :create, parent_resource: :bib, bib_id: parent, box: attributes }
      it { expect(parent.boxes.last.name).to eq attributes[:name]}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end
  
  describe "DELETE destory" do
    let(:parent) { FactoryGirl.create(:bib) }
    let(:child) { FactoryGirl.create(:box) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent
      child
    end
    it {expect {delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id, association_name: :boxes}.to change(Box, :count).by(0)}
    context "parent bib" do
      let(:parent) { FactoryGirl.create(:bib) }
      before do
        parent.boxes << child
        delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id, association_name: :boxes
      end
      it { expect(parent.boxes.exists?(id: child.id)).to be false }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
  end
  
end