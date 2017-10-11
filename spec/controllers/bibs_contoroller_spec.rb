require 'spec_helper'
include ActionDispatch::TestProcess

describe BibsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:bib_1) { FactoryGirl.create(:bib, name: "hoge") }
    let(:bib_2) { FactoryGirl.create(:bib, name: "bib_2") }
    let(:bib_3) { FactoryGirl.create(:bib, name: "bib_3") }
    before do
      bib_1;bib_2;bib_3
      get :index
    end
    it { expect(assigns(:search).class).to eq Ransack::Search }
    it { expect(assigns(:bibs).count).to eq 3 }
  end
  
  describe "GET show" do
    let(:bib) { FactoryGirl.create(:bib) }
    before { get :show, id: bib.id }
    it{ expect(assigns(:bib)).to eq bib }
  end
  
  describe "GET edit" do
    let(:bib) { FactoryGirl.create(:bib) }
    before { get :edit, id: bib.id }
    it{ expect(assigns(:bib)).to eq bib }
  end
  
  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "bib_name", author_ids: ["#{author_id}"]} }
      let(:author_id) { FactoryGirl.create(:author, name: "name_1").id }
      it { expect { post :create, bib: attributes }.to change(Bib, :count).by(1) }
      it "assigns a newly created bib as @bib" do
        post :create, bib: attributes
        expect(assigns(:bib)).to be_persisted
        expect(assigns(:bib).name).to eq(attributes[:name])
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: "", author_ids: [""]} }
      before { allow_any_instance_of(Bib).to receive(:save).and_return(false) }
      it { expect { post :create, bib: attributes }.not_to change(Bib, :count) }
      it "assigns a newly created bib as @bib" do
        post :create, bib: attributes
        expect(assigns(:bib)).to be_new_record
        expect(assigns(:bib).name).to eq(attributes[:name])
      end
    end
  end
  
  describe "PUT update" do
    before do
      bib
      put :update, id: bib.id, bib: attributes
    end
    let(:bib) { FactoryGirl.create(:bib) }
    let(:attributes) { {name: "update_name"} }
    it { expect(assigns(:bib)).to eq bib }
    it { expect(assigns(:bib).name).to eq attributes[:name] }
  end

  describe "PUT publish" do
    before do
      bib
      put :publish, id: bib.id
    end
    let(:bib) { FactoryGirl.create(:bib) }
    #let(:attributes) { {name: "update_name"} }
    it { expect(assigns(:bib)).to eq bib }
    #it { expect(assigns(:bib).published).to be_truthy }
  end

  
  describe "DELETE destroy" do
    let(:bib) { FactoryGirl.create(:bib) }
    before { bib }
    it { expect { delete :destroy, id: bib.id }.to change(Bib, :count).by(-1) }
  end
  
  describe "GET picture" do
    let(:bib) { FactoryGirl.create(:bib) }
    before { get :picture, id: bib.id }
    it { expect(assigns(:bib)).to eq bib }
  end
  
  describe "GET property" do
    let(:bib) { FactoryGirl.create(:bib) }
    before { get :property, id: bib.id }
    it { expect(assigns(:bib)).to eq bib }
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryGirl.create(:bib, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:bib, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:bib, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, ids: ids
    end
    it {expect(assigns(:bibs).include?(obj1)).to be_truthy}
    it {expect(assigns(:bibs).include?(obj2)).to be_truthy}
    it {expect(assigns(:bibs).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3name){"obj3"}
    let(:obj1) { FactoryGirl.create(:bib, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:bib, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:bib, name: obj3name) }
    let(:attributes) { {name: "update_name"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, ids: ids,bib: attributes
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.name).to eq attributes[:name]}
    it {expect(obj2.name).to eq attributes[:name]}
    it {expect(obj3.name).to eq obj3name}
  end
  
  describe "GET download_to_tex" do
    after { get :download_to_tex, ids: params_ids }
    let(:bib) { FactoryGirl.create(:bib) }
    let(:params_ids) { [bib.id.to_s] }
    let(:tex) { double(:tex) }
    let(:bibs) { Bib.all }
    before do
      bib
      allow(Bib).to receive(:where).with(id: params_ids).and_return(bibs)
      allow(Bib).to receive(:build_bundle_tex).with(bibs).and_return(tex)
      allow(controller).to receive(:send_data).and_return{controller.render nothing: true}
    end
    it { expect(controller).to receive(:send_data).with(tex, filename: "bibs.bib", type: "text") }
  end

end
