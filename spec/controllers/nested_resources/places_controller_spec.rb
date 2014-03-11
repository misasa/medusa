require 'spec_helper'

describe NestedResources::PlacesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  
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
  
end
