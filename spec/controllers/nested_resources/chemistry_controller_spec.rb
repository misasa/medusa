require 'spec_helper'

describe NestedResources::ChemistriesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET multiple_new" do
    let(:parent){FactoryGirl.create(:analysis) }
    let(:category_measurement_item){FactoryGirl.create(:category_measurement_item)}
    context "error measurement_category_id" do
      before{get :multiple_new,parent_resourece: :analysis,analysis_id: parent,measurement_category_id: 0}
      it{ expect(assigns(:chemistries).count).to eq 0}
    end
    context "get 1 recored" do
      before{get :multiple_new,parent_resourece: :analysis,analysis_id: parent,measurement_category_id: category_measurement_item.measurement_category_id}
      it{ expect(assigns(:chemistries).count).to eq 1}
      it{ expect(assigns(:chemistries)[0].analysis_id).to eq parent.id}
      it{ expect(assigns(:chemistries)[0].measurement_item_id).to eq category_measurement_item.measurement_item_id}
      it{ expect(assigns(:chemistries)[0].unit_id).to eq category_measurement_item.measurement_item.unit_id}
      it{expect(response).to render_template("multiple_new") }
    end
  end

  describe "POST multiple_create" do
    let(:parent){FactoryGirl.create(:analysis) }
    let(:measurement_item){FactoryGirl.create(:measurement_item) }
    let(:measurement_item2){FactoryGirl.create(:measurement_item) }
    let(:unit){FactoryGirl.create(:unit) }
    let(:parent){FactoryGirl.create(:analysis) }
    let(:attributes) {[{measurement_item_id: measurement_item.id,unit_id: unit.id,value: 1,uncertainty: 1},{measurement_item_id: measurement_item2.id,unit_id: unit.id,value: 2,uncertainty: 2}] }

    it { expect {post :multiple_create, parent_resource: :analysis, analysis_id: parent, chemistries: attributes}.to change(Chemistry, :count).by(attributes.count) }
    context "parent analysis" do
      before{post :multiple_create, parent_resource: :analysis, analysis_id: parent, chemistries: attributes}
      it{ expect(parent.chemistries.last.measurement_item_id).to eq attributes.last[:measurement_item_id]}
      it { expect(response).to redirect_to analysis_path(parent)}
    end
  end

  describe "POST create" do
    let(:measurement_item){FactoryGirl.create(:measurement_item) }
    let(:unit){FactoryGirl.create(:unit) }
    let(:parent){FactoryGirl.create(:analysis) }
    let(:attributes) { {measurement_item_id: measurement_item.id,unit_id: unit.id,value: 1,uncertainty: 1} }
    before {request.env["HTTP_REFERER"]  = "where_i_came_from"}
    it { expect {post :create, parent_resource: :analysis, analysis_id: parent, chemistry: attributes}.to change(Chemistry, :count).by(1) }
    context "parent analysis" do
      before{post :create, parent_resource: :analysis, analysis_id: parent, chemistry: attributes}
      it{ expect(parent.chemistries.last.measurement_item_id).to eq attributes[:measurement_item_id]}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe "DELETE destory" do
    let(:parent){FactoryGirl.create(:analysis) }
    let(:child){FactoryGirl.create(:chemistry)}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent.chemistries << child
    end
    it  {expect {delete :destroy, analysis_id: parent,id: child.id}.to change(Chemistry, :count).by(-1)}
    context "parent analysis" do
      before{ delete :destroy, analysis_id: parent, id: child.id}
      it {expect(parent.chemistries.exists?(id: child.id)).to be false}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe ".add_tab_param" do
    let(:tabname){"chemistry"}
    let(:parent){FactoryGirl.create(:analysis) }
    let(:child){FactoryGirl.create(:chemistry) }
    let(:base_url){"http://wwww.test.co.jp/"}
    before do
      request.env["HTTP_REFERER"]  = url
      delete :destroy, analysis_id: parent,id: child.id,tab: tab
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

