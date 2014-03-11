require 'spec_helper'

describe NestedResources::BibsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

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

end
