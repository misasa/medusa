require 'spec_helper'

describe NestedResources::TablesController do
  let(:parent_name){ :bib }
  let(:child_name){ :table }
  let(:parent) { FactoryGirl.create(parent_name) }
  let(:child) { FactoryGirl.create(child_name) }
  let(:specimen) { FactoryGirl.create(:specimen) }
  let(:user) { FactoryGirl.create(:user) }
  let(:url){ "where_i_came_from" }
  let(:attributes) { {description: description} }
  let(:description) { "description" }
  before do
    request.env["HTTP_REFERER"] = url
    parent
    parent.specimens << specimen
    child
    sign_in user
  end

  describe "POST create" do
    let(:method) { post :create, parent_resource: parent_name, bib_id: parent, table: attributes }
    before { child }
    it { expect{ method }.to change(Table, :count).by(1) }
    context "valid" do
      before { 
        method 
      }
      it { expect(parent.tables.exists?(description: description)).to eq true }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end

    context "with flag_ignore_take_over_specimen" do
      let(:attributes) { {description: description, flag_ignore_take_over_specimen: true} }
      before { 
        method 
      }
      it { expect(parent.tables.exists?(description: description)).to eq true }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end

  end

  describe "PUT update" do
    let(:method) { put :update, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :bibs }
    let(:child_id) { child.id }
    it { expect { method }.to change(Table, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(assigns(child_name)).to eq child }
      it { expect(parent.tables.exists?(id: child.id)).to eq true }
    end
    context "none child" do
      let(:child_id) { 0 }
      it { expect{ method }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
  
  describe "DELETE destory" do
    let(:method) { delete :destroy, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :bibs}
    let(:child_id) { child.id }
    before { parent.tables << child }
    it { expect{ method }.to change(Table, :count).by(-1) }
    context "present child" do
      before { method }
      it { expect(parent.tables.exists?(id: child.id)).to eq false }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "none child" do
      let(:child_id) { 0 }
      it { expect{ method }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
  
  describe "POST link_by_global_id" do
    let(:method) { post :link_by_global_id, parent_resource: parent_name, bib_id: parent.id, global_id: global_id }
    context "present child" do
      let(:global_id) { child.global_id }
      before { method }
      it { expect(parent.tables.exists?(id: child.id)).to eq true }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "none child" do
      let(:global_id) { "aaaa" }
      before { method }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "occur raise" do
      before { allow(Table).to receive(:joins).and_raise }
      context "format html" do
        before do
          post :link_by_global_id, parent_resource: parent_name, bib_id: parent.id, global_id: child.global_id, format: :html
        end
        it { expect(response.body).to render_template("parts/duplicate_global_id") }
        it { expect(response.status).to eq 422 }
      end
      context "format json" do
        before do
          post :link_by_global_id, parent_resource: parent_name, bib_id: parent.id, global_id: child.global_id, format: :json
        end
        it { expect(response.body).to be_blank }
        it { expect(response.status).to eq 422 }
      end
    end
  end

end
