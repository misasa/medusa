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
    context "record found pml " do
      let(:stone) { FactoryGirl.create(:stone) }
      let(:analysis){ FactoryGirl.create(:analysis, stone_id: stone.id ) }
      before do
        stone
        analysis
        get :show, id: stone.record_property.global_id ,format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{stone.global_id}") }    

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
    context "record not found pml" do
      before do
        get :show, id: "not_found_id" ,format: :pml
      end
      it { expect(response.body).to be_blank }
      it { expect(response.status).to eq 404 }
    end

  end

  describe "GET ancestors" do
    let(:root) { FactoryGirl.create(:stone, name: "root") }
    let(:child_1){ FactoryGirl.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:analysis_1){ FactoryGirl.create(:analysis, stone_id: root.id ) }
    let(:analysis_2){ FactoryGirl.create(:analysis, stone_id: child_1.id ) }
    let(:analysis_3){ FactoryGirl.create(:analysis, stone_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :ancestors, id: child_1_1.record_property.global_id, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }    
    end
    context "with format json" do
      before do
        get :ancestors, id: child_1_1.record_property.global_id, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }    
    end
  end

  describe "GET descendants" do
    let(:root) { FactoryGirl.create(:stone, name: "root") }
    let(:child_1){ FactoryGirl.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:analysis_1){ FactoryGirl.create(:analysis, stone_id: root.id ) }
    let(:analysis_2){ FactoryGirl.create(:analysis, stone_id: child_1.id ) }
    let(:analysis_3){ FactoryGirl.create(:analysis, stone_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :descendants, id: root.record_property.global_id, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }    
    end
    context "with format json" do
      before do
        get :descendants, id: root.record_property.global_id, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }    
    end
  end

  describe "GET self_and_descendants" do
    let(:root) { FactoryGirl.create(:stone, name: "root") }
    let(:child_1){ FactoryGirl.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:analysis_1){ FactoryGirl.create(:analysis, stone_id: root.id ) }
    let(:analysis_2){ FactoryGirl.create(:analysis, stone_id: child_1.id ) }
    let(:analysis_3){ FactoryGirl.create(:analysis, stone_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :self_and_descendants, id: root.record_property.global_id, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }    
    end
    context "with format json" do
      before do
        get :self_and_descendants, id: root.record_property.global_id, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }      
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }    
    end
  end

  describe "GET families" do
    let(:root) { FactoryGirl.create(:stone, name: "root") }
    let(:child_1){ FactoryGirl.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:analysis_1){ FactoryGirl.create(:analysis, stone_id: root.id ) }
    let(:analysis_2){ FactoryGirl.create(:analysis, stone_id: child_1.id ) }
    let(:analysis_3){ FactoryGirl.create(:analysis, stone_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :families, id: child_1.record_property.global_id, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }    
    end
    context "with format json" do
      before do
        get :families, id: child_1.record_property.global_id, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }      
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }    
    end
  end

  describe "GET root" do
    let(:root) { FactoryGirl.create(:stone, name: "root") }
    let(:child_1){ FactoryGirl.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:analysis_1){ FactoryGirl.create(:analysis, stone_id: root.id ) }
    let(:analysis_2){ FactoryGirl.create(:analysis, stone_id: child_1.id ) }
    let(:analysis_3){ FactoryGirl.create(:analysis, stone_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :root, id: child_1_1.record_property.global_id, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{root.global_id}") }    
    end
    context "with format json" do
      before do
        get :root, id: child_1_1.record_property.global_id, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{root.global_id}\"") }
    end
  end

  describe "GET parent" do
    let(:root) { FactoryGirl.create(:stone, name: "root") }
    let(:child_1){ FactoryGirl.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:analysis_1){ FactoryGirl.create(:analysis, stone_id: root.id ) }
    let(:analysis_2){ FactoryGirl.create(:analysis, stone_id: child_1.id ) }
    let(:analysis_3){ FactoryGirl.create(:analysis, stone_id: child_1_1.id ) }
    before do
      root;child_1;child_1_1;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :parent, id: child_1_1.record_property.global_id, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1.global_id}") }    
    end
    context "with format json" do
      before do
        get :parent, id: child_1_1.record_property.global_id, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1.global_id}\"") }
    end
  end


  describe "GET siblings" do
    let(:root) { FactoryGirl.create(:stone, name: "root") }
    let(:child_1){ FactoryGirl.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:child_1_2){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:child_1_3){ FactoryGirl.create(:stone, parent_id: child_1.id) }

    let(:analysis_1){ FactoryGirl.create(:analysis, stone_id: child_1_1.id ) }
    let(:analysis_2){ FactoryGirl.create(:analysis, stone_id: child_1_2.id ) }
    let(:analysis_3){ FactoryGirl.create(:analysis, stone_id: child_1_3.id ) }
    before do
      root;child_1;child_1_1;child_1_2;child_1_3;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :siblings, id: child_1_1.record_property.global_id, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_3.global_id}") }    
    end
    context "with format json" do
      before do
        get :siblings, id: child_1_1.record_property.global_id, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_2.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_3.global_id}\"") }
    end
  end

  describe "GET daughters" do
    let(:root) { FactoryGirl.create(:stone, name: "root") }
    let(:child_1){ FactoryGirl.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:child_1_2){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:child_1_3){ FactoryGirl.create(:stone, parent_id: child_1.id) }

    let(:analysis_1){ FactoryGirl.create(:analysis, stone_id: child_1_1.id ) }
    let(:analysis_2){ FactoryGirl.create(:analysis, stone_id: child_1_2.id ) }
    let(:analysis_3){ FactoryGirl.create(:analysis, stone_id: child_1_3.id ) }
    before do
      root;child_1;child_1_1;child_1_2;child_1_3;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :daughters, id: child_1.record_property.global_id, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_3.global_id}") }    
    end
    context "with format json" do
      before do
        get :daughters, id: child_1.record_property.global_id, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }      
      it { expect(response.body).to include("\"global_id\":\"#{child_1_2.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_3.global_id}\"") }
    end
  end

  describe "GET self_and_siblings" do
    let(:root) { FactoryGirl.create(:stone, name: "root") }
    let(:child_1){ FactoryGirl.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:child_1_2){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    let(:child_1_3){ FactoryGirl.create(:stone, parent_id: child_1.id) }

    let(:analysis_1){ FactoryGirl.create(:analysis, stone_id: child_1_1.id ) }
    let(:analysis_2){ FactoryGirl.create(:analysis, stone_id: child_1_2.id ) }
    let(:analysis_3){ FactoryGirl.create(:analysis, stone_id: child_1_3.id ) }
    before do
      root;child_1;child_1_1;child_1_2;child_1_3;
      analysis_1;analysis_2;analysis_3;
    end
    context "with format pml" do
      before do
        get :self_and_siblings, id: child_1_1.record_property.global_id, format: :pml
      end
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{child_1_3.global_id}") }    
    end
    context "with format json" do
      before do
        get :self_and_siblings, id: child_1_1.record_property.global_id, format: :json
      end
      it { expect(response.body).to include("\"global_id\":\"#{child_1_1.global_id}\"") }      
      it { expect(response.body).to include("\"global_id\":\"#{child_1_2.global_id}\"") }
      it { expect(response.body).to include("\"global_id\":\"#{child_1_3.global_id}\"") }
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
  
  describe "GET casteml" do
    let(:obj) { FactoryGirl.create(:stone) }
    let(:analysis_1){ FactoryGirl.create(:analysis, :stone_id => obj.id )}
    let(:analysis_2){ FactoryGirl.create(:analysis, :stone_id => obj.id )}
    let(:casteml){[analysis_2, analysis_1].to_pml}
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
