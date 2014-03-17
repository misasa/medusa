require 'spec_helper'

describe NestedResources::ChemistriesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "POST create" do
    let(:measurement_item){FactoryGirl.create(:measurement_item) }
    let(:unit){FactoryGirl.create(:unit) }
    let(:parent){FactoryGirl.create(:analysis) }
    let(:attributes) { {measurement_item_id: measurement_item.id,unit_id: unit.id,value: 1,uncertainty: 1} }
    before {request.env["HTTP_REFERER"]  = "where_i_came_from"}
    it { expect {post :create, parent_resource: :analysis, analysis_id: parent, chemistry: attributes}.to change(Chemistry, :count).by(1) }
    context "parent analysis" do
      before{post :create, parent_resource: :analysis, analysis_id: parent, chemistry: attributes}
      it{ expect(parent.chemistries.last.measurement_item_id).to eq attributes[:measurement_item_id]}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe "DELETE destory" do
    let(:parent){FactoryGirl.create(:analysis) }
    let(:child){FactoryGirl.create(:chemistry)}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent.chemistries << child
    end
    it  {expect {delete :destroy, analysis_id: parent,id: child.id}.to change(Chemistry, :count).by(-1)}
    context "parent analysis" do
      before{ delete :destroy, analysis_id: parent, id: child.id}
      it {expect(parent.chemistries.exists?(id: child.id)).to be false}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

end
