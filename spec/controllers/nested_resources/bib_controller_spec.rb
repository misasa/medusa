require 'spec_helper'

describe NestedResources::BibsController do
  let(:parent_name){:analysis}
  let(:child_name){:bib}
  let(:parent) { FactoryBot.create(parent_name) }
  let(:child) { FactoryBot.create(child_name) }
  let(:user) { FactoryBot.create(:user) }
  let(:url){"where_i_came_from"}
  let(:author_id) { FactoryBot.create(:author).id }
  let(:attributes) { {name: name, author_ids: ["#{author_id}"]} }
  let(:name){"child_name"}
  before { request.env["HTTP_REFERER"]  = url }
  before { sign_in user }
  before { parent }
  before { child }

  describe "POST create" do
    let(:method){post :create, params: { parent_resource: parent_name, analysis_id: parent, bib: attributes }}
    before{child}
    it { expect{method}.to change(Bib, :count).by(1) }
    context "validate" do
      before { method }
      it { expect(parent.bibs.exists?(name: name)).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "invalidate" do
      let(:name){""}
      before { method }
      it { expect {method}.to change(Bib, :count).by(0) }
      it { expect(parent.bibs.exists?(name: name)).to eq false}
      it { expect(response).to render_template("error")}
    end
  end

  describe "PUT update" do
    let(:method){put :update, params: { parent_resource: parent_name, analysis_id: parent, id: child_id, association_name: :analysiss }}
    let(:child_id){child.id}
    it { expect {method}.to change(Bib, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(assigns(child_name)).to eq child }
      it { expect(parent.bibs.exists?(id: child.id)).to eq true}
    end
    context "none child" do
      let(:child_id){0}
      it { expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end
  describe "DELETE destory" do
    let(:method){delete :destroy, params: { parent_resource: parent_name, analysis_id: parent, id: child_id, association_name: :analysiss }}
    before { parent.bibs << child}
    let(:child_id){child.id}
    it { expect {method}.to change(Bib, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(parent.bibs.exists?(id: child.id)).to eq false}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "none child" do
      let(:child_id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end
  describe "POST link_by_global_id" do
    let(:method){post :link_by_global_id, params: { parent_resource: parent_name,analysis_id: parent.id, global_id: global_id }}
    context "present child" do
      let(:global_id){child.global_id}
      before { method }
      it { expect(parent.bibs.exists?(id: child.id)).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "none child" do
      let(:global_id){"aaaa"}
      before { method }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "occur raise" do
      before { allow(Bib).to receive(:joins).and_raise }
      context "format html" do
        before do
          post :link_by_global_id, params: { parent_resource: parent_name, analysis_id: parent.id, global_id: child.global_id, format: :html }
        end
        it { expect(response.body).to render_template("parts/duplicate_global_id") }
        it { expect(response.status).to eq 422 }
      end
      context "format json" do
        before do
          post :link_by_global_id, params: { parent_resource: parent_name, analysis_id: parent.id, global_id: child.global_id, format: :json }
        end
        it { expect(response.body).to be_blank }
        it { expect(response.status).to eq 422 }
      end
    end
  end

end
