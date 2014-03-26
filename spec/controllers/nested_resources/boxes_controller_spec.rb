require 'spec_helper'

describe NestedResources::BoxesController do
  let(:parent_name){:bib}
  let(:child_name){:box}
  let(:parent) { FactoryGirl.create(parent_name) }
  let(:child) { FactoryGirl.create(child_name) }
  let(:user) { FactoryGirl.create(:user) }
  let(:url){"where_i_came_from"}
  let(:name){"child_name"}
  let(:attributes) { {name: name} }
  before { request.env["HTTP_REFERER"]  = url }
  before { sign_in user }
  before { parent }
  before { child }

  describe "POST create" do
    let(:method){post :create, parent_resource: parent_name, bib_id: parent, box: attributes, association_name: :boxes}
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
    let(:method){put :update, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :boxes}
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
    let(:method){delete :destroy, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :boxes}
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
    let(:method){post :link_by_global_id, parent_resource: parent_name,bib_id: parent.id, global_id: global_id, association_name: :boxes}
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
  end

end
