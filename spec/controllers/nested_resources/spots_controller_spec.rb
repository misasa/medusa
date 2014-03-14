require 'spec_helper'

describe NestedResources::SpotsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "POST create" do
    let(:parent){FactoryGirl.create(:attachment_file) }
    let(:attributes) { {name: "spot_name",spot_x: 0,spot_y:0} }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
    end
    it { expect {post :create, parent_resource: :attachment_file, attachment_file_id: parent, spot: attributes}.to change(Spot, :count).by(1) }
    context "parent attachment_file" do
      let(:parent){FactoryGirl.create(:attachment_file) }
      before{post :create, parent_resource: :attachment_file, attachment_file_id: parent, spot: attributes}
      it{ expect(parent.spots.last.name).to eq attributes[:name]}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe "PUT update" do
    let(:parent){FactoryGirl.create(:attachment_file) }
    let(:child){FactoryGirl.create(:spot) }
    let(:attributes) { {name: "update_name"} }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent.spots << child
    end
    it { expect {put :update, attachment_file_id: parent, id: child.id, spot: attributes}.to change(Spot, :count).by(0) }
    context "parent attachment_file" do
      before{put :update, attachment_file_id: parent,id: child.id, spot: attributes}
      it{ expect(parent.spots.last.name).to eq attributes[:name]}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe "DELETE destory" do
    let(:parent){FactoryGirl.create(:attachment_file) }
    let(:child){FactoryGirl.create(:spot)}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent
      child
    end
    it  {expect {delete :destroy, attachment_file_id: parent,id: child.id}.to change(Spot, :count).by(-1)}
    context "parent attachment_file" do
      before do
        parent.spots << child
        delete :destroy, attachment_file_id: parent, id: child.id
      end
      it {expect(parent.spots.exists?(id: child.id)).to be false}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

end
