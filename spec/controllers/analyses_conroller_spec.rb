require 'spec_helper'
include ActionDispatch::TestProcess

describe AnalysesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:obj_1) { FactoryGirl.create(:analysis, name: "hoge") }
    let(:obj_2) { FactoryGirl.create(:analysis, name: "analysis_2") }
    let(:obj_3) { FactoryGirl.create(:analysis, name: "analysis_3") }
    before do
      obj_1;obj_2;obj_3
      get :index
    end
    it { expect(assigns(:analyses).count).to eq 3 }
  end

  describe "GET show" do
    let(:method){get :show, id: id}
    let(:obj) { FactoryGirl.create(:analysis) }
    context "record found" do
      let(:id){obj.id}
      before { method }
      it{ expect(assigns(:analysis)).to eq obj }
    end
    context "record not found" do
      let(:id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "GET edit" do
    let(:method){get :edit, id: id}
    let(:obj) { FactoryGirl.create(:analysis) }
    context "record found" do
      let(:id){obj.id}
      before { method }
      it{ expect(assigns(:analysis)).to eq obj }
    end
    context "record not found" do
      let(:id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "POST create" do
    let(:attributes) { {name: "obj_name"} }
    it { expect { post :create, analysis: attributes }.to change(Analysis, :count).by(1) }
    describe "assigns as @analysis" do
      before{ post :create, analysis: attributes }
      it{ expect(assigns(:analysis)).to be_persisted }
      it { expect(assigns(:analysis).name).to eq attributes[:name] }
    end
  end

  describe "PUT update" do
    let(:method){put :update, id: id, analysis: attributes}
    let(:obj) { FactoryGirl.create(:analysis) }
    let(:attributes) { {name: "update_name"} }
    context "record found" do
      let(:id){obj.id}
      before { method }
      it { expect(assigns(:analysis)).to eq obj }
      it { expect(assigns(:analysis).name).to eq attributes[:name] }
    end
    context "record not found " do
      let(:id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryGirl.create(:analysis, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:analysis, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:analysis, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, ids: ids
    end
    it {expect(assigns(:analyses).include?(obj1)).to be_truthy}
    it {expect(assigns(:analyses).include?(obj2)).to be_truthy}
    it {expect(assigns(:analyses).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3name){"obj3"}
    let(:obj1) { FactoryGirl.create(:analysis, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:analysis, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:analysis, name: obj3name) }
    let(:attributes) { {name: "update_name"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, ids: ids,analysis: attributes
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.name).to eq attributes[:name]}
    it {expect(obj2.name).to eq attributes[:name]}
    it {expect(obj3.name).to eq obj3name}
  end

  describe "GET picture" do
    let(:obj) { FactoryGirl.create(:analysis) }
    before { get :picture, id: obj.id }
    it { expect(assigns(:analysis)).to eq obj }
  end

  describe "GET property" do
    let(:obj) { FactoryGirl.create(:analysis) }
    before { get :property, id: obj.id }
    it { expect(assigns(:analysis)).to eq obj }
  end

  describe "POST import" do
    let(:data) { double(:upload_data) }
    before do
      allow(Analysis).to receive(:import_csv).with(data.to_s).and_return(import_result)
      post :import, data: data
    end
    context "import success" do
      let(:import_result) { true }
      it { expect(response).to redirect_to(analyses_path) }
    end
    context "import false" do
      let(:import_result) { false }
      it { expect(response).to render_template("import_invalid") }
    end
  end

  describe "GET table" do
    let(:obj) { FactoryGirl.create(:analysis) }
    let(:obj2) { FactoryGirl.create(:analysis) }
    let(:objs){ [obj,obj2]}
    before { get :table, ids: objs.map {|obj| obj.id} }
    it { expect(assigns(:analyses)).to eq objs }
    it { expect(response).to render_template("table") }
  end

  describe "GET castemls" do
    let(:obj) { FactoryGirl.create(:analysis) }
    let(:obj2) { FactoryGirl.create(:analysis) }
    let(:objs){ [obj,obj2]}
    let(:castemls){Analysis.to_castemls(objs)}
    after{get :castemls, ids: objs.map {|obj| obj.id} }
    it { expect(controller).to receive(:send_data).with(castemls, filename: "my-great-analysis.pml", type: "application/xml", disposition: "attached").and_return{controller.render nothing: true} }
  end

end
