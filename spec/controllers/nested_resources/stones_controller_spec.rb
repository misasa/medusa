require 'spec_helper'

describe NestedResources::StonesController do
  let(:parent) { FactoryGirl.create(:bib) }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "POST create" do
    let(:attributes) { {name: name} }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
    end
    context "validate" do
      let(:name){"stone_name"}
      it { expect {post :create, parent_resource: :bib, bib_id: parent, stone: attributes, association_name: :stones}.to change(Stone, :count).by(1) }
      context "parent bib" do
        before { post :create, parent_resource: :bib, bib_id: parent, stone: attributes , association_name: :stones}
        it { expect(parent.stones.last.name).to eq attributes[:name]}
        it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
      end
    end
    context "invalidate" do
      let(:name){""}
      it { expect {post :create, parent_resource: :bib, bib_id: parent, stone: attributes, association_name: :stones}.to change(Stone, :count).by(0) }
      context "parent bib" do
        before { post :create, parent_resource: :bib, bib_id: parent, stone: attributes, association_name: :stones} 
        it { expect(response).to render_template("error")}
      end
    end
  end

  describe "DELETE destory" do
    let(:child){FactoryGirl.create(:stone)}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent
      child
    end
    it  {expect {delete :destroy, parent_resource: :bib, bib_id: parent,id: child.id,association_name: :stones}.to change(Stone, :count).by(0)}
    context "parent bib" do
      before do
        parent.stones.clear
        parent.stones << child
        delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id,association_name: :stones
      end
      it {expect(parent.stones.exists?(id: child.id)).to be false}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "parent bib" do
      before do
        parent.stones << child
        delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id,association_name: :stones
      end
      it {expect(parent.stones.exists?(id: child.id)).to be false}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "parent bib" do
      before do
        parent.stones << child
        delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id,association_name: :stones
      end
      it {expect(parent.stones.exists?(id: child.id)).to be false}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end
  
  describe "POST link_by_global_id" do
    let(:child){FactoryGirl.create(:stone) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      child.record_property.global_id = "test_global_id"
      child.record_property.save
      post :link_by_global_id, parent_resource: :bib, bib_id: parent.id, global_id: child.global_id, association_name: :stones
    end
    it { expect(parent.stones[0]).to eq(child)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
  end

end
