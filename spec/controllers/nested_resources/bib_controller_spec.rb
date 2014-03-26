require 'spec_helper'

describe NestedResources::BibsController do
  let(:parent) { FactoryGirl.create(:analysis) }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "POST create" do
    let(:author_id) { FactoryGirl.create(:author).id } 
    let(:attributes) { {name: name, author_ids: ["#{author_id}"]} }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
    end
    context "validate" do
      let(:name){"bib_name"}
      it { expect {post :create, parent_resource: :analysis, analysis_id: parent, bib: attributes}.to change(Bib, :count).by(1) }
      context "parent analysis" do
        before { post :create, parent_resource: :analysis, analysis_id: parent, bib: attributes }
        it { expect(parent.bibs.last.name).to eq attributes[:name]}
        it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
      end
    end
    context "invalidate" do
      let(:name){""}
      it { expect {post :create, parent_resource: :analysis, analysis_id: parent, bib: attributes}.to change(Bib, :count).by(0) }
      context "parent analysis" do
        before { post :create, parent_resource: :analysis, analysis_id: parent, bib: attributes }
        it { expect(response).to render_template("error")}
      end

    end
  end

  describe "DELETE destory" do
    let(:child){FactoryGirl.create(:bib)}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent
      child
    end
    it  {expect {delete :destroy, parent_resource: :analysis, analysis_id: parent,id: child.id}.to change(Bib, :count).by(0)}
    context "parent analysis" do
      before do
        parent.bibs << child
        delete :destroy, parent_resource: :analysis, analysis_id: parent, id: child.id
      end
      it {expect(parent.bibs.count).to eq 0}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe "POST link_by_global_id" do
    let(:child){FactoryGirl.create(:bib) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      child.record_property.global_id = "test_global_id"
      child.record_property.save
      post :link_by_global_id, parent_resource: :analysis, analysis_id: parent.id, global_id: child.global_id
    end
    it { expect(parent.bibs[0]).to eq(child)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
  end

  describe ".add_tab_param" do
    let(:tabname){"bib"}
    let(:child){FactoryGirl.create(:bib) }
    let(:base_url){"http://wwww.test.co.jp/"}
    before do
      request.env["HTTP_REFERER"]  = url
      child.record_property.global_id = "test_global_id"
      child.record_property.save
      post :link_by_global_id, parent_resource: :analysis, analysis_id: parent.id, global_id: child.global_id, association_name: :bibs, tab: tab 
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
