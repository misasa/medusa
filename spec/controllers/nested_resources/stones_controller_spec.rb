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
      let(:parent){FactoryGirl.create(:place) }
      before{post :create, parent_resource: :place, place_id: parent, stone: attributes}
      it{ expect(parent.stones.last.name).to eq attributes[:name]}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

end
