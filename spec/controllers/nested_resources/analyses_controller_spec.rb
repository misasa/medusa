require 'spec_helper'

describe NestedResources::AnalysesController do
  let(:parent) { FactoryGirl.create(:bib) }
  let(:child) { FactoryGirl.create(:analysis) }
  let(:user) { FactoryGirl.create(:user) }
  let(:url){"where_i_came_from"}
  let(:attributes) { {name: name} }
  before { request.env["HTTP_REFERER"]  = url }
  before { sign_in user }
  before { parent }
  
  describe "POST create" do
    context "validate" do
      let(:name){"analysis_name"}
      it { expect {post :create, parent_resource: :bib, bib_id: parent, analysis: attributes}.to change(Analysis, :count).by(1) }
      context "parent analysis" do
        before { post :create, parent_resource: :bib, bib_id: parent, analysis: attributes }
        it { expect(parent.analyses.last.name).to eq attributes[:name]}
        it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
      end
    end
    context "invalidate" do
      let(:name){""}
      it { expect {post :create, parent_resource: :bib, bib_id: parent, analysis: attributes}.to change(Analysis, :count).by(0) }
      context "parent analysis" do
        before { post :create, parent_resource: :bib, bib_id: parent, analysis: attributes }
        it { expect(response).to render_template("error")}
      end
    end
  end
  
  describe "DELETE destory" do
    before { child }
    it {expect {delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id, association_name: :analyses}.to change(Analysis, :count).by(0)}
    context "parent analysis" do
      before do
        parent.analyses << child
        delete :destroy, parent_resource: :bib, bib_id: parent, id: child.id, association_name: :analyses
      end
      it { expect(parent.analyses.exists?(id: child.id)).to be false }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
  end

  describe "POST link_by_global_id" do
    before do
      child.record_property.global_id = "test_global_id"
      child.record_property.save
      post :link_by_global_id, parent_resource: :bib,bib_id: parent.id, global_id: child.global_id
    end
    it { expect(parent.analyses[0]).to eq(child)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
  end

  describe ".add_tab_param" do
    let(:tabname){"analysis"}
    let(:base_url){"http://wwww.test.co.jp/"}
    before do
      child.record_property.global_id = "test_global_id"
      child.record_property.save
      post :link_by_global_id, parent_resource: :bib, bib_id: parent.id, global_id: child.global_id, association_name: :analysiss, tab: tab 
    end
    context "add none param" do
      let(:tab){""}
      let(:url){base_url}
      it { expect(response).to redirect_to base_url}
    end
    context "add param" do
      let(:tab){tabname}
      context "1st param" do
        let(:url){base_url}
        it { expect(response).to redirect_to base_url + "?tab=" + tabname}
      end
      context "2nd param" do
        let(:url){base_url + "?aaa=aaa"}
        it { expect(response).to redirect_to base_url + "?aaa=aaa&tab=" + tabname}
      end
      context "exsist tab param other param" do
        let(:url){base_url + "?tab=aaa&aaa=aaa"}
        it { expect(response).to redirect_to base_url + "?aaa=aaa&tab=" + tabname}
      end
      context "exsist tab param other none param" do
        let(:url){base_url + "?tab=aaa"}
        it { expect(response).to redirect_to base_url + "?tab=" + tabname}
      end
    end
  end

end
