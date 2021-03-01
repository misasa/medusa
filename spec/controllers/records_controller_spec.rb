require 'spec_helper'

describe RecordsController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:specimen) { FactoryBot.create(:specimen) }
    let(:box) { FactoryBot.create(:box) }
    let(:analysis) { FactoryBot.create(:analysis) }
    let(:bib) { FactoryBot.create(:bib) }
    let(:place) { FactoryBot.create(:place) }
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    let(:allcount){Specimen.count + Box.count + Analysis.count + Bib.count + Place.count + AttachmentFile.count}
    before do
      specimen
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

    context "with format pml" do
      before do
        get :index, format: 'pml'
      end
      it { expect(assigns(:records).size).to eq(allcount) }
      it { expect(response.body).to include("\<global_id\>#{analysis.global_id}") }

    end

  end

  describe "GET show" do

    context "record found json " do
      let(:specimen) { FactoryBot.create(:specimen) }
      before do
        specimen
        get :show, params: { id: specimen.record_property.global_id ,format: :json }
      end
      #it { expect(response.body).to include(specimen.to_json) }
      it {
        json = JSON.parse(response.body)
        expect(json["datum_attributes"]["name"]).to eql(specimen.name)
        expect(json["datum_attributes"]["global_id"]).to eql(specimen.global_id)
      }
    end
    context "record found html " do
      let(:specimen) { FactoryBot.create(:specimen) }
      before do
        specimen
        get :show, params: { id: specimen.record_property.global_id ,format: :html }
      end
      it { expect(response).to  redirect_to(controller: "specimens",action: "show",id:specimen.id) }
    end
    context "record found pml " do
      let(:specimen) { FactoryBot.create(:specimen) }
      let(:analysis){ FactoryBot.create(:analysis, specimen_id: specimen.id ) }
      before do
        specimen
        analysis
        get :show, params: { id: specimen.record_property.global_id ,format: :pml }
      end
      it { expect(response.body).to include("\<sample_global_id\>#{specimen.global_id}") }

    end
    context "record not found json" do
      before do
        get :show, params: { id: "not_found_id" ,format: :json }
      end
      it { expect(response.body).to be_blank }
      it { expect(response.status).to eq 404 }
    end
    context "record not found html" do
      before do
        get :show, params: { id: "not_found_id" ,format: :html }
      end
      it { expect(response).to render_template("record_not_found") }
      it { expect(response.status).to eq 404 }
    end
    context "record not found pml" do
      before do
        get :show, params: { id: "not_found_id" ,format: :pml }
      end
      it { expect(response.body).to be_blank }
      it { expect(response.status).to eq 404 }
    end

  end

  describe "GET ancestors" do
    let(:root) { FactoryBot.create(:specimen, name: "root") }
    let(:child_1){ FactoryBot.create(:specimen, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:analysis_1){ FactoryBot.create(:analysis, specimen_id: root.id ) }
    let(:analysis_2){ FactoryBot.create(:analysis, specimen_id: child_1.id ) }
    let(:analysis_3){ FactoryBot.create(:analysis, specimen_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :ancestors, params: { id: child_1_1.record_property.global_id, format: :pml }
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }
    end
    context "with format json" do
      before do
        get :ancestors, params: { id: child_1_1.record_property.global_id, format: :json }
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }
    end
  end

  describe "GET descendants" do
    let(:root) { FactoryBot.create(:specimen, name: "root") }
    let(:child_1){ FactoryBot.create(:specimen, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:analysis_1){ FactoryBot.create(:analysis, specimen_id: root.id ) }
    let(:analysis_2){ FactoryBot.create(:analysis, specimen_id: child_1.id ) }
    let(:analysis_3){ FactoryBot.create(:analysis, specimen_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :descendants, params: { id: root.record_property.global_id, format: :pml }
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }
    end
    context "with format json" do
      before do
        get :descendants, params: { id: root.record_property.global_id, format: :json }
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }
    end
  end

  describe "GET self_and_descendants" do
    let(:root) { FactoryBot.create(:specimen, name: "root") }
    let(:child_1){ FactoryBot.create(:specimen, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:analysis_1){ FactoryBot.create(:analysis, specimen_id: root.id ) }
    let(:analysis_2){ FactoryBot.create(:analysis, specimen_id: child_1.id ) }
    let(:analysis_3){ FactoryBot.create(:analysis, specimen_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :self_and_descendants, params: { id: root.record_property.global_id, format: :pml }
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }
    end
    context "with format json" do
      before do
        get :self_and_descendants, params: { id: root.record_property.global_id, format: :json }
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }
    end
  end

  describe "GET pmlame" do
    let!(:root) { FactoryBot.create(:specimen, name: "root") }
    let!(:child_1){ FactoryBot.create(:specimen, parent_id: root.id) }
    let!(:child_1_1){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let!(:analysis_1){ FactoryBot.create(:analysis, specimen_id: root.id ) }
    let!(:analysis_2){ FactoryBot.create(:analysis, specimen_id: child_1.id ) }
    let!(:analysis_3){ FactoryBot.create(:analysis, specimen_id: child_1_1.id ) }

    context "type is none" do
      before do
        get :pmlame, params: { id: child_1.record_property.global_id, format: :json }
      end
      it { expect(response.body).not_to include("\"sample_id\":\"#{root.global_id}\"") }
      it { expect(response.body).to include("\"sample_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"sample_id\":\"#{child_1.global_id}\"") }
    end
    context "type is family" do
      before do
        get :pmlame, params: { id: child_1.record_property.global_id, format: :json, type: "family" }
      end
      it { expect(response.body).to include("\"sample_id\":\"#{root.global_id}\"") }
      it { expect(response.body).to include("\"sample_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"sample_id\":\"#{child_1.global_id}\"") }
    end
  end

  describe "GET families" do
    let(:root) { FactoryBot.create(:specimen, name: "root") }
    let(:child_1){ FactoryBot.create(:specimen, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:analysis_1){ FactoryBot.create(:analysis, specimen_id: root.id ) }
    let(:analysis_2){ FactoryBot.create(:analysis, specimen_id: child_1.id ) }
    let(:analysis_3){ FactoryBot.create(:analysis, specimen_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :families, params: { id: child_1.record_property.global_id, format: :pml }
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }
    end
    context "with format json" do
      before do
        get :families, params: { id: child_1.record_property.global_id, format: :json }
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }
    end
  end

  describe "GET root" do
    let(:root) { FactoryBot.create(:specimen, name: "root") }
    let(:child_1){ FactoryBot.create(:specimen, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:analysis_1){ FactoryBot.create(:analysis, specimen_id: root.id ) }
    let(:analysis_2){ FactoryBot.create(:analysis, specimen_id: child_1.id ) }
    let(:analysis_3){ FactoryBot.create(:analysis, specimen_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :root, params: { id: child_1_1.record_property.global_id, format: :pml }
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }
    end
    context "with format json" do
      before do
        get :root,params: {  id: child_1_1.record_property.global_id, format: :json }
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }
    end
  end

  describe "GET parent" do
    let(:root) { FactoryBot.create(:specimen, name: "root") }
    let(:child_1){ FactoryBot.create(:specimen, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:analysis_1){ FactoryBot.create(:analysis, specimen_id: root.id ) }
    let(:analysis_2){ FactoryBot.create(:analysis, specimen_id: child_1.id ) }
    let(:analysis_3){ FactoryBot.create(:analysis, specimen_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :parent, params: { id: child_1_1.record_property.global_id, format: :pml }
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }
    end
    context "with format json" do
      before do
        get :parent, params: { id: child_1_1.record_property.global_id, format: :json }
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }
    end
  end


  describe "GET siblings" do
    let(:root) { FactoryBot.create(:specimen, name: "root") }
    let(:child_1){ FactoryBot.create(:specimen, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:child_1_2){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:child_1_3){ FactoryBot.create(:specimen, parent_id: child_1.id) }

    let(:analysis_1){ FactoryBot.create(:analysis, specimen_id: child_1_1.id ) }
    let(:analysis_2){ FactoryBot.create(:analysis, specimen_id: child_1_2.id ) }
    let(:analysis_3){ FactoryBot.create(:analysis, specimen_id: child_1_3.id ) }
    before do
      root;child_1;child_1_1;child_1_2;child_1_3;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :siblings, params: { id: child_1_1.record_property.global_id, format: :pml }
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_2.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_3.global_id}") }
    end
    context "with format json" do
      before do
        get :siblings, params: { id: child_1_1.record_property.global_id, format: :json }
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_2.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_3.global_id}\"") }
    end
  end

  describe "GET daughters" do
    let(:root) { FactoryBot.create(:specimen, name: "root") }
    let(:child_1){ FactoryBot.create(:specimen, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:child_1_2){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:child_1_3){ FactoryBot.create(:specimen, parent_id: child_1.id) }

    let(:analysis_1){ FactoryBot.create(:analysis, specimen_id: child_1_1.id ) }
    let(:analysis_2){ FactoryBot.create(:analysis, specimen_id: child_1_2.id ) }
    let(:analysis_3){ FactoryBot.create(:analysis, specimen_id: child_1_3.id ) }
    before do
      root;child_1;child_1_1;child_1_2;child_1_3;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :daughters, params: { id: child_1.record_property.global_id, format: :pml }
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_2.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_3.global_id}") }
    end
    context "with format json" do
      before do
        get :daughters, params: { id: child_1.record_property.global_id, format: :json }
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_2.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_3.global_id}\"") }
    end
  end

  describe "GET self_and_siblings" do
    let(:root) { FactoryBot.create(:specimen, name: "root") }
    let(:child_1){ FactoryBot.create(:specimen, parent_id: root.id) }
    let(:child_1_1){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:child_1_2){ FactoryBot.create(:specimen, parent_id: child_1.id) }
    let(:child_1_3){ FactoryBot.create(:specimen, parent_id: child_1.id) }

    let(:analysis_1){ FactoryBot.create(:analysis, specimen_id: child_1_1.id ) }
    let(:analysis_2){ FactoryBot.create(:analysis, specimen_id: child_1_2.id ) }
    let(:analysis_3){ FactoryBot.create(:analysis, specimen_id: child_1_3.id ) }
    before do
      root;child_1;child_1_1;child_1_2;child_1_3;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :self_and_siblings, params: { id: child_1_1.record_property.global_id, format: :pml }
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_2.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_3.global_id}") }
    end
    context "with format json" do
      before do
        get :self_and_siblings, params: { id: child_1_1.record_property.global_id, format: :json }
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_2.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_3.global_id}\"") }
    end
  end

  describe "GET property" do
    context "record found json" do
      let(:specimen) { FactoryBot.create(:specimen) }
      before do
        specimen
        get :property, params: { id: specimen.record_property.global_id ,format: :json }
      end
      it { expect(response.body).to eq(specimen.record_property.to_json) }
    end
    context "record found html" do
      let(:specimen) { FactoryBot.create(:specimen) }
      before do
        specimen
        get :property, params: { id: specimen.record_property.global_id ,format: :html }
      end
      pending { expect(response).to render_template("") }
    end
    context "record not found json" do
      before do
        get :property, params: { id: "not_found_id" ,format: :json }
      end
      it { expect(response.body).to be_blank }
      it { expect(response.status).to eq 404 }
    end
    context "record not found html" do
      before do
        get :property, params: { id: "not_found_id" ,format: :html }
      end
      it { expect(response).to render_template("record_not_found") }
      it { expect(response.status).to eq 404 }
    end
  end

  describe "GET casteml" do
    let(:obj) { FactoryBot.create(:specimen) }
    let(:analysis_1){ FactoryBot.create(:analysis, :specimen_id => obj.id )}
    let(:analysis_2){ FactoryBot.create(:analysis, :specimen_id => obj.id )}
    let(:casteml){[analysis_2, analysis_1].to_pml}
    before do
      obj
      analysis_1
      analysis_2
    end
    after{get :casteml, params: { id: obj.global_id }}
    #it { expect(controller).to receive(:send_data).with(casteml, {type: "application/xml", filename: obj.global_id + ".pml", disposition: "attached"}){controller.head:no_content} }
    it { expect(controller).to receive(:send_data).with(/<?xml/, {type: "application/xml", filename: obj.global_id + ".pml", disposition: "attached"}){controller.head:no_content} }
  end

  describe "PUT dispose" do
    let!(:specimen) { FactoryBot.create(:specimen) }
    it { expect { put :dispose, params: { id: specimen.record_property.global_id }}.to change{ specimen.record_property.reload.disposed }.from(false).to(true) }
  end

  describe "PUT restore" do
    let!(:specimen) { FactoryBot.create(:specimen) }
    before do
      specimen.record_property.disposed = true
      specimen.record_property.save!
    end
    it { expect { put :restore, params: { id: specimen.record_property.global_id }}.to change{ specimen.record_property.reload.disposed }.from(true).to(false) }
  end

  describe "PUT lose" do
    let!(:specimen) { FactoryBot.create(:specimen) }
    it { expect { put :lose, params: { id: specimen.record_property.global_id }}.to change{ specimen.record_property.reload.lost }.from(false).to(true) }
  end

  describe "PUT found" do
    let!(:specimen) { FactoryBot.create(:specimen) }
    before do
      specimen.record_property.lost = true
      specimen.record_property.save!
    end
    it { expect { put :found, params: { id: specimen.record_property.global_id }}.to change{ specimen.record_property.reload.lost }.from(true).to(false) }
  end

  describe "DELETE destroy" do
    let(:specimen) { FactoryBot.create(:specimen) }
    before { specimen }
    it { expect { delete :destroy, params: { id: specimen.record_property.global_id }}.to change(RecordProperty, :count).by(-1) }
  end
end
