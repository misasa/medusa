require 'spec_helper'

describe NestedResources::BoxesController do
  let(:parent_name){:bib}
  let(:child_name){:box}
  let(:parent) { FactoryBot.create(parent_name) }
  let(:child) { FactoryBot.create(child_name) }
  let(:user) { FactoryBot.create(:user) }
  let(:url){"where_i_came_from"}
  let(:name){"child_name"}
  let(:attributes) { {name: name} }
  before { request.env["HTTP_REFERER"]  = url }
  before { sign_in user }
  before { parent }
  before { child }

  describe "POST create" do
    let(:method){post :create, params: { parent_resource: parent_name, bib_id: parent, box: attributes, association_name: :boxes }}
    before{child}
    it { expect{method}.to change(Box, :count).by(1) }
    context "validate" do
      before { method }
      it { expect(parent.boxes.exists?(name: name)).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "invalidate" do
      let(:name){""}
      before { method }
      it { expect {method}.to change(Box, :count).by(0) }
      it { expect(parent.boxes.exists?(name: name)).to eq false}
      it { expect(response).to render_template("error")}
    end
  end

  describe "PUT update" do
    let(:method){put :update, params: { parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :boxes }}
    let(:child_id){child.id}
    it { expect {method}.to change(Box, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(assigns(child_name)).to eq child }
      it { expect(parent.boxes.exists?(id: child.id)).to eq true}
    end
    context "none child" do
      let(:child_id){0}
      it { expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "DELETE destory" do
    let(:method){delete :destroy, params: { parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :boxes }}
    before { parent.boxes << child}
    let(:child_id){child.id}
    it { expect {method}.to change(Box, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(parent.boxes.exists?(id: child.id)).to eq false}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "none child" do
      let(:child_id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "POST link_by_global_id" do
    let(:method){post :link_by_global_id, params: { parent_resource: parent_name,bib_id: parent.id, global_id: global_id, association_name: :boxes }}
    context "present child" do
      let(:global_id){child.global_id}
      before { method }
      it { expect(parent.boxes.exists?(id: child.id)).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "none child" do
      let(:global_id){"aaaa"}
      before { method }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "occur raise" do
      before { allow(Box).to receive(:joins).and_raise }
      context "format html" do
        before do
          post :link_by_global_id, params: { parent_resource: parent_name.to_s, bib_id: parent.id, global_id: child.global_id, format: :html }
        end
        it { expect(response.body).to render_template("parts/duplicate_global_id") }
        it { expect(response.status).to eq 422 }
      end
      context "format json" do
        before do
          post :link_by_global_id, params: { parent_resource: parent_name.to_s, bib_id: parent.id, global_id: child.global_id, format: :json }
        end
        it { expect(response.body).to be_blank }
        it { expect(response.status).to eq 422 }
      end
    end
  end

  describe "POST inventory" do
    let!(:box1) { FactoryBot.create(:box) }
    let!(:box2) { FactoryBot.create(:box, parent_id: box1.id) }
    let!(:box3) { FactoryBot.create(:box) }
    let!(:now) { Time.now }
    let(:parent_name) { :box }
    before do
      allow(Time).to receive(:now).and_return( now )
      post :inventory, params: { parent_resource: parent_name, box_id: box_id, id: box2.id, association_name: :boxes }
    end
    context "not changed parent_id" do
      let(:box_id) { box1.id }
      it { expect(assigns(:box).parent_id).to eq box1.id  }
      it { expect(assigns(:box).updated_at).not_to eq now  }
    end
    context "changed parent_id" do
      let(:box_id) { box3.id }
      it { expect(assigns(:box).parent_id).to eq box3.id  }
      it { expect(assigns(:box).updated_at).to eq now  }
    end
  end

end
