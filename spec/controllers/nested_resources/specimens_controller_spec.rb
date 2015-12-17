require 'spec_helper'

describe NestedResources::SpecimensController do
  let(:parent_name){:bib}
  let(:child_name){:specimen}
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
    let(:method){post :create, parent_resource: parent_name, bib_id: parent, specimen: attributes, association_name: :specimens}
    before{child}
    it { expect{method}.to change(Specimen, :count).by(1) }
    context "validate" do
      before { method }
      it { expect(parent.specimens.exists?(name: name)).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "invalidate" do
      context "nameなし" do
        let(:name){""}
        before { method }
        it { expect {method}.to change(Analysis, :count).by(0) }
        it { expect(parent.specimens.exists?(name: name)).to eq false}
        it { expect(response).to render_template("error")}
      end
      context "name同じ" do
        let(:attributes) {{name: name, box_id: id}}
        let(:name) {child.name}
        let(:id) {child.box_id}
        it { expect{method}.to change(Specimen, :count).by(0) }
      end
    end
  end

  describe "PUT update" do
    let(:method){put :update, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :specimens}
    let(:child_id){child.id}
    it { expect {method}.to change(Specimen, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(assigns(child_name)).to eq child }
      it { expect(parent.specimens.exists?(id: child.id)).to eq true}
    end
    context "none child" do
      let(:child_id){0}
      it { expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "DELETE destory" do
    let(:method){delete :destroy, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :specimens}
    before { parent.specimens << child}
    let(:child_id){child.id}
    it { expect {method}.to change(Specimen, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(parent.specimens.exists?(id: child.id)).to eq false}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "none child" do
      let(:child_id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "PUT update" do
    let(:method){put :update, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :specimens}
    let(:child_id){child.id}
    it { expect {method}.to change(Specimen, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(assigns(child_name)).to eq child }
      it { expect(parent.specimens.exists?(id: child.id)).to eq true}
    end
    context "none child" do
      let(:child_id){0}
      it { expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end
  describe "DELETE destory" do
    let(:method){delete :destroy, parent_resource: parent_name, bib_id: parent, id: child_id, association_name: :specimens}
    before { parent.specimens << child}
    let(:child_id){child.id}
    it { expect {method}.to change(Specimen, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(parent.specimens.exists?(id: child.id)).to eq false}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "none child" do
      let(:child_id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "POST link_by_global_id" do
    let(:method){post :link_by_global_id, parent_resource: parent_name,bib_id: parent.id, global_id: global_id , association_name: :specimens}
    context "present child" do
      let(:global_id){child.global_id}
      before { method }
      it { expect(parent.specimens.exists?(id: child.id)).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "none child" do
      let(:global_id){"aaaa"}
      before { method }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "occur raise" do
      before { allow(Specimen).to receive(:joins).and_raise }
      context "format html" do
        before do
          post :link_by_global_id, parent_resource: parent_name.to_s, bib_id: parent.id, global_id: child.global_id, format: :html
        end
        it { expect(response.body).to render_template("parts/duplicate_global_id") }
        it { expect(response.status).to eq 422 }
      end
      context "format json" do
        before do
          post :link_by_global_id, parent_resource: parent_name.to_s, bib_id: parent.id, global_id: child.global_id, format: :json
        end
        it { expect(response.body).to be_blank }
        it { expect(response.status).to eq 422 }
      end
    end
  end
  
  describe "POST inventory" do
    let!(:specimen) { FactoryGirl.create(:specimen) }
    let!(:box) { FactoryGirl.create(:box) }
    let!(:now) { Time.now }
    let(:parent_name) { :box }
    before do
      allow(Time).to receive(:now).and_return( now )
      post :inventory, parent_resource: parent_name, box_id: box_id, id: specimen.id, association_name: :specimens
    end
    context "not changed box_id" do
      let(:box_id) { specimen.box_id }
      it { expect(assigns(:specimen).box_id).to eq specimen.box_id  }
      it { expect(assigns(:specimen).updated_at).not_to eq now  }
    end
    context "changed box_id" do
      let(:box_id) { box.id }
      it { expect(assigns(:specimen).box_id).to eq box.id  }
      it { expect(assigns(:specimen).updated_at).to eq now  }
    end
  end

end
