require 'spec_helper'

describe NestedResources::AnalysesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  
  describe "POST create" do
    let(:parent) { FactoryGirl.create(:bib) }
    let(:attributes) { {name: "analysis_name"} }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
    end
    it { expect {post :create, parent_resource: :bib, bib_id: parent, analysis: attributes}.to change(Analysis, :count).by(1) }
    context "parent analysis" do
      before { post :create, parent_resource: :bib, bib_id: parent, analysis: attributes }
      it { expect(parent.analyses.last.name).to eq attributes[:name]}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end
  
  describe "DELETE destory" do
    let(:parent) { FactoryGirl.create(:bib) }
    let(:child) { FactoryGirl.create(:analysis) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent
      child
    end
    it {expect {delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id, association_name: :analyses}.to change(Analysis, :count).by(0)}
    context "parent analysis" do
      let(:parent) { FactoryGirl.create(:bib) }
      before do
        parent.analyses << child
        delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id, association_name: :analyses
      end
      it { expect(parent.analyses.exists?(id: child.id)).to be false }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
  end
  
end
