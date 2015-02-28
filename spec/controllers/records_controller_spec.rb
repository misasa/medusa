require 'spec_helper'

describe RecordsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:stone) { FactoryGirl.create(:stone) }
    let(:box) { FactoryGirl.create(:box) }
    let(:analysis) { FactoryGirl.create(:analysis) }
    let(:bib) { FactoryGirl.create(:bib) }
    let(:place) { FactoryGirl.create(:place) }
    let(:attachment_file) { FactoryGirl.create(:attachment_file) }
    let(:allcount){Stone.count + Box.count + Analysis.count + Bib.count + Place.count + AttachmentFile.count}
    before do
      stone
      box
      analysis
      bib
      place
      attachment_file
#      get :index
    end

    context "without format" do
      before do
        get :index
      end
      it { expect(assigns(:records_search).class).to eq Ransack::Search }
      it { expect(assigns(:records).size).to eq(allcount) }
    end

    context "with format json" do
      before do
        get :index, format: 'json'
      end
      it { expect(assigns(:records).size).to eq(allcount) }
      it { expect(response.body).to include("\"global_id\":") }
      it { expect(response.body).to include("\"datum_id\":") }      
      it { expect(response.body).to include("\"datum_type\":") }      
      it { expect(response.body).to include("\"datum_attributes\":") }      

    end

  end

  describe "GET show" do
    context "record found json " do
      let(:stone) { FactoryGirl.create(:stone) }
      before do
        stone
        get :show, id: stone.record_property.global_id ,format: :json
      end
      it { expect(response.body).to include(stone.to_json) }
    end
    context "record found html " do
      let(:stone) { FactoryGirl.create(:stone) }
      before do
        stone
        get :show, id: stone.record_property.global_id ,format: :html
      end
      it { expect(response).to  redirect_to(controller: "stones",action: "show",id:stone.id) }
    end
    context "record not found json" do
      before do
        get :show, id: "not_found_id" ,format: :json
      end
      it { expect(response.body).to be_blank }
      it { expect(response.status).to eq 404 }
    end
    context "record not found html" do
      before do
        get :show, id: "not_found_id" ,format: :html
      end
      it { expect(response).to render_template("record_not_found") }
      it { expect(response.status).to eq 404 }
    end
  end

  describe "GET property" do
    context "record found json" do
      let(:stone) { FactoryGirl.create(:stone) }
      before do
        stone
        get :property, id: stone.record_property.global_id ,format: :json
      end
      it { expect(response.body).to eq(stone.record_property.to_json) }
    end
    context "record found html" do
      let(:stone) { FactoryGirl.create(:stone) }
      before do
        stone
        get :property, id: stone.record_property.global_id ,format: :html
      end
      pending { expect(response).to render_template("") }
    end
    context "record not found json" do
      before do
        get :property, id: "not_found_id" ,format: :json
      end
      it { expect(response.body).to be_blank }
      it { expect(response.status).to eq 404 }
    end
    context "record not found html" do
      before do
        get :property, id: "not_found_id" ,format: :html
      end
      it { expect(response).to render_template("record_not_found") }
      it { expect(response.status).to eq 404 }
    end
  end
  
  describe "GET casteml", :current => true do
    let(:obj) { FactoryGirl.create(:stone) }
    let(:analysis_1){ FactoryGirl.create(:analysis, :stone_id => obj.id )}
    let(:analysis_2){ FactoryGirl.create(:analysis, :stone_id => obj.id )}
    let(:casteml){Analysis.to_castemls([analysis_2, analysis_1])}
    before do
      obj
      analysis_1
      analysis_2      
    end
    after{get :casteml, id: obj.global_id }
    it { expect(controller).to receive(:send_data).with(casteml, {type: "application/xml", filename: obj.global_id + ".pml", disposition: "attached"}).and_return{controller.render nothing: true} }
  end

  describe "DELETE destroy" do
    let(:stone) { FactoryGirl.create(:stone) }
    before { stone }
    it { expect { delete :destroy, id: stone.record_property.global_id }.to change(RecordProperty, :count).by(-1) }
  end
end
