require 'spec_helper'
include ActionDispatch::TestProcess

describe PlacesController do
  let(:user) { FactoryGirl.create(:user, :username => "user_1") }
  before { sign_in user }

  describe "GET index" do
    let(:place_1) { FactoryGirl.create(:place, :name => "place_1") }
    let(:place_2) { FactoryGirl.create(:place, :name => "place_2") }
    let(:place_3) { FactoryGirl.create(:place, :name => "hoge") }
    let(:record_property_1) { RecordProperty.find_by(datum_id: place_1.id) }
    let(:record_property_2) { RecordProperty.find_by(datum_id: place_2.id) }
    let(:record_property_3) { RecordProperty.find_by(datum_id: place_3.id) }
    let(:user_2) { FactoryGirl.create(:user, :username => "test_2", :email => "email@test_2.co.jp") }
    let(:user_3) { FactoryGirl.create(:user, :username => "test_3", :email => "email@hoge.co.jp") }
    let(:group_1) { FactoryGirl.create(:group, :name => "group_1") }
    let(:group_2) { FactoryGirl.create(:group, :name => "hoge") }
    let(:group_3) { FactoryGirl.create(:group, :name => "group_3") }
    let(:params) { {q: query} }

    let(:specimen_1) { FactoryGirl.create(:specimen, name: "hoge", place_id: place_1.id) }
    let(:specimen_2) { FactoryGirl.create(:specimen, name: "specimen_2", place_id: place_2.id) }
    let(:specimen_3) { FactoryGirl.create(:specimen, name: "specimen_3", place_id: place_3.id) }
    let(:analysis_1) { FactoryGirl.create(:analysis, specimen_id: specimen_1.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, specimen_id: specimen_2.id) }
    let(:analysis_3) { FactoryGirl.create(:analysis, specimen_id: specimen_3.id) }

    before do
      place_1
      place_2
      place_3
      specimen_1;specimen_2;specimen_3;      
      analysis_1;analysis_2;analysis_3;      
      record_property_1.update_attribute(:group_id, group_1.id)
      record_property_2.update_attributes(:user_id => user_2.id, :group_id => group_2.id, :guest_readable => true, :guest_writable => true)
      record_property_3.update_attributes(:user_id => user_3.id, :group_id => group_3.id, :guest_readable => true, :guest_writable => true)
#      get :index, params
    end
    describe "search" do
      before do
        get :index, params
      end
      context "name search" do
        let(:query) { {"name_cont" => "place"} }
        it { expect(assigns(:places)).to eq [place_2, place_1] }
      end
      context "owner search" do
        let(:query) { {"user_username_cont" => "test"} }
        it { expect(assigns(:places)).to eq [place_3, place_2] }
      end
      context "group search" do
        let(:query) { {"group_name_cont" => "group"} }
        it { expect(assigns(:places)).to eq [place_3, place_1] }
      end
    end
    describe "sort" do
      before do
        get :index, params
      end

      let(:params) { {q: query, page: 2, per_page: 1} }
      context "sort condition is present" do
        let(:query) { {"name_cont" => "place", "s" => "updated_at DESC"} }
        it { expect(assigns(:places)).to eq [place_1] }
      end
      context "sort condition is nil" do
        let(:query) { {"name_cont" => "place"} }
        it { expect(assigns(:places)).to eq [place_1] }
      end
    end

    context "with format 'pml'" do
      before do
        get :index, format: 'pml'
      end
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_3.global_id}") } 
    end
  end

  # send_data test returns unexpected object.
  describe "GET new" do
  end

  describe "GET show" do
    let(:obj){FactoryGirl.create(:place) }
    let(:specimen_1) { FactoryGirl.create(:specimen, name: "hoge", place_id: obj.id) }
    let(:specimen_2) { FactoryGirl.create(:specimen, name: "specimen_2", place_id: obj.id) }
    let(:specimen_3) { FactoryGirl.create(:specimen, name: "specimen_3", place_id: obj.id) }
    let(:analysis_1) { FactoryGirl.create(:analysis, specimen_id: specimen_1.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, specimen_id: specimen_2.id) }
    let(:analysis_3) { FactoryGirl.create(:analysis, specimen_id: specimen_3.id) }
    before do
      specimen_1;specimen_2;specimen_3;      
      analysis_1;analysis_2;analysis_3;
    end
    context "without format" do    
      before{get :show,id:obj.id}
      it{expect(assigns(:place)).to eq obj}
      it{expect(response).to render_template("show") }
    end

    context "with format 'pml'" do
      before { get :show, id: obj.id, format: 'pml' }
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_3.global_id}") }    
    end

  end

  describe "GET edit" do
    let(:place) { FactoryGirl.create(:place) }
    before { get :edit, id: place.id }
    it { expect(assigns(:place)).to eq place }
  end

  describe "POST create" do
    let(:attributes) { {name: "place_name"} }
    it { expect {post :create ,place: attributes}.to change(Place, :count).by(1) }
    context "create" do
      before{post :create ,place: attributes}
      it{expect(assigns(:place).name).to eq attributes[:name]}
    end
  end

  describe "PUT update" do
    let(:obj){FactoryGirl.create(:place) }
    let(:attributes) { {name: "update_name"} }
    it { expect {put :update ,id: obj.id,place: attributes}.to change(Place, :count).by(0) }
    before do
      obj
      put :update, id: obj.id, place: attributes
    end
    it{expect(assigns(:place).name).to eq attributes[:name]}
  end

  describe "GET map" do
    let(:obj){FactoryGirl.create(:place) }
    before{get :map,id:obj.id}
    it{expect(assigns(:place)).to eq obj}
    it{expect(response).to render_template("map") }
  end

  describe "GET property" do
    let(:obj){FactoryGirl.create(:place) }
    before{get :property,id:obj.id}
    it{expect(assigns(:place)).to eq obj}
    it{expect(response).to render_template("property") }
  end

  describe "DELETE destroy" do
    let(:obj){FactoryGirl.create(:place) }
    before { obj }
    it { expect{delete :destroy,id: obj.id}.to change(Place, :count).by(-1) }
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryGirl.create(:place, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:place, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:place, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, ids: ids
    end
    it {expect(assigns(:places).include?(obj1)).to be_truthy}
    it {expect(assigns(:places).include?(obj2)).to be_truthy}
    it {expect(assigns(:places).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3name){"obj3"}
    let(:obj1) { FactoryGirl.create(:place, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:place, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:place, name: obj3name) }
    let(:attributes) { {name: "update_name"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, ids: ids,place: attributes
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.name).to eq attributes[:name]}
    it {expect(obj2.name).to eq attributes[:name]}
    it {expect(obj3.name).to eq obj3name}
  end
  
  describe "GET download_bundle_card" do
    # send_data
  end
  
  # send_data test returns unexpected object.
  pending "GET download_label" do
  end
  
  describe "GET download_bundle_label" do
    after { get :download_bundle_label, ids: params_ids }
    let(:place) { FactoryGirl.create(:place) }
    let(:params_ids) { [place.id.to_s] }
    let(:label) { double(:label) }
    let(:places) { Place.all }
    before do
      place
      allow(Place).to receive(:where).with(id: params_ids).and_return(places)
      allow(Place).to receive(:build_bundle_label).with(places).and_return(label)
      allow(controller).to receive(:send_data).and_return{controller.render nothing: true}
    end
    it { expect(controller).to receive(:send_data).with(label, filename: "places.label", type: "text/label") }
  end

  describe "POST import" do
    let(:data) { double(:upload_data) }
    context "return raise" do
      before do
        allow(Place).to receive(:import_csv).with(data.to_s).and_raise("error")
        post :import, data: data
      end
      it { expect(response).to render_template("import_invalid") }
    end
    context "return no error" do
      before do
        allow(Place).to receive(:import_csv).with(data.to_s).and_return(import_result)
        post :import, data: data
      end
      context "import success" do
        let(:import_result) { true }
        it { expect(response).to redirect_to(places_path) }
      end
      context "import false" do
        let(:import_result) { false }
        it { expect(response).to render_template("import_invalid") }
      end
    end
  end

end
