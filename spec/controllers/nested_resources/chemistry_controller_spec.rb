require 'spec_helper'

describe NestedResources::ChemistriesController do
  let(:parent_name){:analysis}
  let(:child_name){:chemistry}
  let(:parent) { FactoryGirl.create(parent_name) }
  let(:child) { FactoryGirl.create(child_name) }
  let(:user) { FactoryGirl.create(:user) }
  let(:url){"where_i_came_from"}
  let(:value){1}
  let(:unit){FactoryGirl.create(:unit) }
  let(:measurement_item) { FactoryGirl.create(:measurement_item) }
  let(:category_measurement_item){FactoryGirl.create(:category_measurement_item)}
  let(:measurement_item_id){measurement_item.id}
  let(:attributes) { {measurement_item_id: measurement_item_id,unit_id: unit.id,value: value ,uncertainty: 1} }
  let(:mesurement_category_id){category_measurement_item.measurement_category_id}
  before { request.env["HTTP_REFERER"]  = url }
  before { sign_in user }
  before { parent }
  before { child }

  describe "GET multiple_new" do
    let(:method){get :multiple_new,parent_resourece: :analysis,analysis_id: parent,measurement_category_id: mesurement_category_id}
    context "error measurement_category_id" do
      let(:mesurement_category_id){0}
      before{method}
      it{ expect(assigns(:chemistries).count).to eq 0}
    end
    context "get 1 recored" do
      before{method}
      it{ expect(assigns(:chemistries).count).to eq 1}
      it{ expect(assigns(:chemistries)[0].analysis_id).to eq parent.id}
      it{ expect(assigns(:chemistries)[0].measurement_item_id).to eq category_measurement_item.measurement_item_id}
      it{ expect(assigns(:chemistries)[0].unit_id).to eq category_measurement_item.measurement_item.unit_id}
      it{expect(response).to render_template("multiple_new") }
    end
  end

  describe "POST multiple_create" do
    let(:method){post :multiple_create, parent_resource: :analysis, analysis_id: parent, chemistries: attributes}
    let(:measurement_item){FactoryGirl.create(:measurement_item) }
    let(:measurement_item2){FactoryGirl.create(:measurement_item) }
    let(:attributes) {[{measurement_item_id: measurement_item.id,unit_id: unit.id,value: 1,uncertainty: 1},{measurement_item_id: measurement_item2.id,unit_id: unit.id,value: 2,uncertainty: 2}] }

    it { expect {method}.to change(Chemistry, :count).by(attributes.count) }
    context "parent analysis" do
      before{method}
      it{ expect(parent.chemistries.last.measurement_item_id).to eq attributes.last[:measurement_item_id]}
      it { expect(response).to redirect_to analysis_path(parent)}
    end
  end

  describe "POST create" do
    let(:method){post :create, parent_resource: parent_name, analysis_id: parent, chemistry: attributes, association_name: :chemistries}
    before{child}
    it { expect{method}.to change(Chemistry, :count).by(1) }
    context "validate" do
      before { method }
      it { expect(parent.chemistries.exists?(measurement_item_id: measurement_item_id)).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "invalidate" do
      let(:value){""}
      before { method }
      it { expect {method}.to change(Chemistry, :count).by(0) }
      it { expect(parent.chemistries.exists?(measurement_item_id: measurement_item_id)).to eq false}
      it { expect(response).to render_template("error")}
    end
  end

  describe "PUT update" do
    let(:method){put :update, parent_resource: parent_name, analysis_id: parent, id: child_id, association_name: :chemistries}
    let(:child_id){child.id}
    it { expect {method}.to change(Chemistry, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(assigns(child_name)).to eq child }
      it { expect(parent.chemistries.exists?(id: child.id)).to eq true}
    end
    context "none child" do
      let(:child_id){0}
      it { expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end
  describe "DELETE destory" do
    let(:method){delete :destroy, parent_resource: parent_name, analysis_id: parent, id: child_id, association_name: :chemistries}
    before { parent.chemistries << child}
    let(:child_id){child.id}
    it { expect {method}.to change(Chemistry, :count).by(-1) }
    context "present child" do
      before { method }
      it { expect(parent.chemistries.exists?(id: child.id)).to eq false}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "none child" do
      let(:child_id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

end
