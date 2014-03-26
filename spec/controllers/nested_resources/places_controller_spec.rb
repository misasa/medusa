require 'spec_helper'

describe NestedResources::PlacesController do
  let(:parent_name){:bib}
  let(:child_name){:place}
  let(:parent) { FactoryGirl.create(parent_name) }
  let(:child) { FactoryGirl.create(child_name) }
  let(:user) { FactoryGirl.create(:user) }
  let(:url){"where_i_came_from"}
  let(:attributes) { {name: name} }
  let(:name){"child_name"}
  before { request.env["HTTP_REFERER"]  = url }
  before { sign_in user }
  before { parent }
  before { child }

  describe "POST create" do
    let(:method){post :create, parent_resource: parent_name, bib_id: parent, place: attributes, association_name: :places}
    before{child}
    it { expect{method}.to change(Place, :count).by(1) }
    context "validate" do
      before { method }
      it { expect(parent.places.exists?(name: name)).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "invalidate" do
      let(:name){""}
      before { method }
      it { expect {method}.to change(Place, :count).by(0) }
      it { expect(parent.places.exists?(name: name)).to eq false}
      it { expect(response).to render_template("error")}
    end
  end
  describe "DELETE destory" do
    let(:method){delete :destroy, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :places}
    before { parent.places << child}
    let(:child_id){child.id}
    it { expect {method}.to change(Place, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(parent.places.exists?(id: child.id)).to eq false}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "none child" do
      let(:child_id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end
  describe "DELETE destory" do
    let(:method){delete :destroy, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :places}
    before { parent.places << child}
    let(:child_id){child.id}
    it { expect {method}.to change(Place, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(parent.places.exists?(id: child.id)).to eq false}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "none child" do
      let(:child_id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "POST link_by_global_id" do
    let(:method){post :link_by_global_id, parent_resource: parent_name,bib_id: parent.id, global_id: global_id }
    context "present child" do
      let(:global_id){child.global_id}
      before { method }
      it { expect(parent.places.exists?(id: child.id)).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "none child" do
      let(:global_id){"aaaa"}
      before { method }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

end
