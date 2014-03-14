require 'spec_helper'

describe NestedResources::PlacesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  
  describe "POST create" do
    let(:parent) { FactoryGirl.create(:bib) }
    let(:attributes) { {name: "place_name"} }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
    end
    it { expect {post :create, parent_resource: :bib, bib_id: parent, place: attributes}.to change(Place, :count).by(1) }
    context "parent place" do
      before { post :create, parent_resource: :bib, bib_id: parent, place: attributes }
      it { expect(parent.places.last.name).to eq attributes[:name]}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end
  
  describe "DELETE destory" do
    let(:parent) { FactoryGirl.create(:bib) }
    let(:child) { FactoryGirl.create(:place) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent
      child
    end
    it {expect {delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id, association_name: :places}.to change(Place, :count).by(0)}
    context "parent bib" do
      let(:parent){FactoryGirl.create(:bib) }
      before do
        parent.places << child
        delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id, association_name: :places
      end
      it { expect(parent.places.exists?(id: child.id)).to be false }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
  end

  describe "POST link_by_global_id" do
    let(:parent){FactoryGirl.create(:bib) }
    let(:child){FactoryGirl.create(:place) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      child.record_property.global_id = "test_global_id"
      child.record_property.save
      post :link_by_global_id, parent_resource: :bib, bib_id: parent.id, global_id: child.global_id, association_name: :places
    end
    it { expect(parent.places[0]).to eq(child)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
  end

end
