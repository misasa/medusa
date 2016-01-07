require 'spec_helper'
include ActionDispatch::TestProcess

describe SpecimensController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:specimen_1) { FactoryGirl.create(:specimen, name: "hoge") }
    let(:specimen_2) { FactoryGirl.create(:specimen, name: "specimen_2") }
    let(:specimen_3) { FactoryGirl.create(:specimen, name: "specimen_3") }
    let(:analysis_1) { FactoryGirl.create(:analysis, specimen_id: specimen_1.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, specimen_id: specimen_2.id) }
    let(:analysis_3) { FactoryGirl.create(:analysis, specimen_id: specimen_3.id) }
    before do
      specimen_1;specimen_2;specimen_3
      get :index
    end
    it { expect(assigns(:specimens).count).to eq 3 }

    context "with format 'json'" do
      before do
        specimen_1;specimen_2;specimen_3
        analysis_1;analysis_2;analysis_3;
        get :index, format: 'json'
      end
      it { expect(response.body).to include("\"global_id\":") }    
    end

    context "with format 'pml'" do
      before do
        specimen_1;specimen_2;specimen_3
        analysis_1;analysis_2;analysis_3;

        get :index, format: 'pml'
      end
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_3.global_id}") }    
    end

  end
  
  describe "GET show", :current => true do
    let(:specimen) { FactoryGirl.create(:specimen) }
    let(:analysis_1) { FactoryGirl.create(:analysis, specimen_id: specimen.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, specimen_id: specimen.id) }
    let(:analysis_3) { FactoryGirl.create(:analysis, specimen_id: specimen.id) }
    before do
      analysis_1;analysis_2;analysis_3;
    end
    context "without format" do
      before { get :show, id: specimen.id }
      it { expect(assigns(:specimen)).to eq specimen }
    end

    context "with format 'json'" do
      before { get :show, id: specimen.id, format: 'json' }
      it { expect(response.body).to include("\"global_id\":") }    
    end

    context "with format 'pml'" do
      before { get :show, id: specimen.id, format: 'pml' }
      it { expect(response.body).to include("\<sample_global_id\>#{specimen.global_id}") }    
    end

  end
  
  describe "GET edit" do
    let(:specimen) { FactoryGirl.create(:specimen) }
    before { get :edit, id: specimen.id }
    it { expect(assigns(:specimen)).to eq specimen }
  end
  
  describe "GET detail_edit" do
    let(:specimen) { FactoryGirl.create(:specimen) }
    let(:specimen_custom_attributes) { double(:specimen_custom_attributes) }
    before do
      allow_any_instance_of(Specimen).to receive(:set_specimen_custom_attributes).and_return(specimen_custom_attributes)
      get :detail_edit, id: specimen.id
    end
    it { expect(assigns(:specimen)).to eq specimen }
    it { expect(assigns(:specimen_custom_attributes)).to eq specimen_custom_attributes }
  end
  
  describe "POST create", :current => true do
    let(:attributes) { {name: "specimen_name" } }
    it { expect { post :create, specimen: attributes }.to change(Specimen, :count).by(1) }
    describe "assigns as @specimen" do
      before { post :create, specimen: attributes }
      it { expect(assigns(:specimen)).to be_persisted }
      it { expect(assigns(:specimen).name).to eq attributes[:name]}
    end
  end
  
  describe "PUT update" do
    before do
      specimen
    end
    let(:specimen) { FactoryGirl.create(:specimen) }
    let(:attributes) { {name: "update_name", age_min: 10, age_max: 20, age_unit: "Ka"} }
    context "witout format" do
      before { put :update, id: specimen.id, specimen:attributes }
      it { expect(assigns(:specimen)).to eq specimen }
      it { expect(assigns(:specimen).name).to eq attributes[:name] }
      it { expect(assigns(:specimen).age_min).to eq attributes[:age_min] }
      it { expect(assigns(:specimen).age_max).to eq attributes[:age_max] }
      it { expect(assigns(:specimen).age_unit).to eq attributes[:age_unit] }
    end
  end
  
  describe "PUT sesar_upload" do
    before do
      specimen
    end
    let(:specimen) { FactoryGirl.create(:specimen, igsn: nil) }
    let(:attributes) { {name: "update_name", age_min: 10, age_max: 20, age_unit: "Ka"} }
    context "save false" do
      before do
        allow_any_instance_of(Sesar).to receive(:save).and_return(false)
        allow_any_instance_of(Sesar).to receive(:igsn).and_return("IESHO0001")
      end
      it "igsnが更新されない" do
        put :update, id: specimen.id, sesar_upload: "", specimen:attributes
        expect(assigns(:specimen).igsn).to eq nil
      end
    end
    context "save_true" do
      before do
        allow_any_instance_of(Sesar).to receive(:save).and_return(true)
        allow_any_instance_of(Sesar).to receive(:igsn).and_return("IESHO0001")
      end
      it "igsnが更新される" do
        put :update, id: specimen.id, sesar_upload: "", specimen:attributes
        expect(assigns(:specimen).igsn).to eq "IESHO0001"
      end
    end
  end


  describe "DELETE destroy" do
    let(:specimen) { FactoryGirl.create(:specimen) }
    before { specimen }
    it { expect { delete :destroy, id: specimen.id }.to change(Specimen, :count).by(-1) }
  end
  
  describe "GET family" do
    let(:specimen) { FactoryGirl.create(:specimen) }
    before { get :family, id: specimen.id }
    it { expect(assigns(:specimen)).to eq specimen }
  end
  
  describe "GET picture" do
    let(:specimen) { FactoryGirl.create(:specimen) }
    before { get :picture, id: specimen.id }
    it { expect(assigns(:specimen)).to eq specimen }
  end
  
  describe "GET map" do
    let(:specimen) { FactoryGirl.create(:specimen) }
    before { get :map, id: specimen.id }
    it { expect(assigns(:specimen)).to eq specimen }
  end
  
  describe "GET show_place", :current => true do
    let(:specimen) { FactoryGirl.create(:specimen, place_id: place.id) }
    let(:place) { FactoryGirl.create(:place) }
    before { get :show_place, id: specimen.id, format: 'html'  }
    it { expect(assigns(:specimen)).to eq specimen }
    it { expect(assigns(:place)).to eq place }

  end

  describe "POST create_place", :current => true do
    let(:specimen) { FactoryGirl.create(:specimen) }
    let(:attributes) { {name: 'test-place', latitude_dms_direction: 'N', latitude_dms_deg: 5, latitude_dms_min: 37, latitude_dms_deg: 30.0, lonigtude_dms_direction: 'E', longitude_dms_deg: 5, elevation: 120} }
    #it { expect { post :create_place, id: specimen.id, place: attributes }.to change(Place, :count).by(1) }
    describe "assigns as @specimen" do
      before { post :create_place, id: specimen.id, place: attributes }
      it { expect(assigns(:specimen).place).not_to be_nil }
      it { expect(assigns(:place)).to be_persisted }
      it { expect(assigns(:place).name).to eq attributes[:name]}
      it { expect(assigns(:place).latitude).not_to be_nil}
      it { expect(assigns(:place).longitude).not_to be_nil}
      it { expect(assigns(:place).elevation).to eq attributes[:elevation]}
    end

    context "without place name" do
      let(:attributes) { {latitude: 123.4, longitude: 56.78, elevation: 120} }
      before { post :create_place, id: specimen.id, place: attributes }
      it { expect(assigns(:specimen).place).not_to be_nil }
      it { expect(assigns(:place)).to be_persisted }
      it { expect(assigns(:place).name).to eq "locality of #{specimen[:name]}" }
    end


  end


  describe "GET property" do
    let(:specimen) { FactoryGirl.create(:specimen) }
    before { get :property, id: specimen.id }
    it { expect(assigns(:specimen)).to eq specimen }
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryGirl.create(:specimen, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:specimen, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:specimen, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, ids: ids
    end
    it {expect(assigns(:specimens).include?(obj1)).to be_truthy}
    it {expect(assigns(:specimens).include?(obj2)).to be_truthy}
    it {expect(assigns(:specimens).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3name){"obj3"}
    let(:obj1) { FactoryGirl.create(:specimen, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:specimen, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:specimen, name: obj3name) }
    let(:attributes) { {name: "update_name"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, ids: ids,specimen: attributes
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.name).to eq attributes[:name]}
    it {expect(obj2.name).to eq attributes[:name]}
    it {expect(obj3.name).to eq obj3name}
  end

  # send_data test returns unexpected object.
  pending "GET download_card" do
    after { get :download_card, id: specimen.id }
    let(:specimen) { FactoryGirl.create(:specimen) }
    before do
      specimen
      allow(Specimen).to receive(:build_card).and_return(double(:report))
      allow(double(:report)).to receive(:generate).and_return(double(:generate))
      allow(controller).to receive(:send_data).and_return{controller.render nothing: true}
    end
    it { expect(controller).to receive(:send_data).with(double(:generate), filename: "specimen.pdf", type: "application/pdf") }
  end

  describe "GET download_bundle_card" do
    # send_data
  end
  
  # send_data test returns unexpected object.
  pending "GET download_label" do
    after { get :download_label, id: specimen.id }
    let(:specimen) { FactoryGirl.create(:specimen) }
    before do
      specimen
      allow(Specimen).to receive(:build_label).and_return(double(:build_label))
      allow(controller).to receive(:send_data).and_return{controller.render nothing: true}
    end
    it { expect(controller).to receive(:send_data).with(double(:build_label), filename: "Specimen_#{specimen.id}.csv", type: "text/csv") }
  end
  
  describe "download_bundle_label" do
    after { get :download_bundle_label, ids: params_ids }
    let(:specimen) { FactoryGirl.create(:specimen) }
    let(:params_ids) { [specimen.id.to_s] }
    let(:label) { double(:label) }
    let(:specimens) { Specimen.all }
    before do
      specimen
      allow(Specimen).to receive(:where).with(id: params_ids).and_return(specimens)
      allow(Specimen).to receive(:build_bundle_label).with(specimens).and_return(label)
      allow(controller).to receive(:send_data).and_return{controller.render nothing: true}
    end
    it { expect(controller).to receive(:send_data).with(label, filename: "specimens.csv", type: "text/csv") }
  end
  
end
