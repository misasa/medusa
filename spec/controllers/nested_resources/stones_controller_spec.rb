require 'spec_helper'

describe NestedResources::StonesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "POST create" do
    let(:parent){FactoryGirl.create(:place) }
    let(:attributes) { {name: "stone_name"} }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
    end
    it { expect {post :create, parent_resource: :place, place_id: parent, stone: attributes}.to change(Stone, :count).by(1) }
    context "parent place" do
      before{post :create, parent_resource: :place, place_id: parent, stone: attributes}
      it{ expect(parent.stones.last.name).to eq attributes[:name]}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe "DELETE destory" do
    let(:parent){FactoryGirl.create(:bib) }
    let(:child){FactoryGirl.create(:stone)}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent
      child
    end
    it  {expect {delete :destroy, parent_resource: :bib, bib_id: parent,id: child.id,association_name: :stones}.to change(Stone, :count).by(0)}
    context "parent place" do
      let(:parent){FactoryGirl.create(:place) }
      before do
        parent.stones.clear
        parent.stones << child
        delete :destroy, parent_resource: :place, place_id: parent, id: child.id,association_name: :stones
      end
      it {expect(parent.stones.exists?(id: child.id)).to be false}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "parent bib" do
      let(:parent){FactoryGirl.create(:bib) }
      before do
        parent.stones << child
        delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id,association_name: :stones
      end
      it {expect(parent.stones.exists?(id: child.id)).to be false}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "parent attachment_file" do
      let(:parent){FactoryGirl.create(:attachment_file) }
      before do
        parent.stones << child
        delete :destroy, parent_resource: :attachment_file, attachment_file_id: parent, id: child.id,association_name: :stones
      end
      it {expect(parent.stones.exists?(id: child.id)).to be false}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end

  end
end