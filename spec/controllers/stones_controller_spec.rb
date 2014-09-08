require 'spec_helper'
include ActionDispatch::TestProcess

describe StonesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:stone_1) { FactoryGirl.create(:stone, name: "hoge") }
    let(:stone_2) { FactoryGirl.create(:stone, name: "stone_2") }
    let(:stone_3) { FactoryGirl.create(:stone, name: "stone_3") }
    before do
      stone_1;stone_2;stone_3
      get :index
    end
    it { expect(assigns(:stones).count).to eq 3 }

    context "with format 'json'" do
      before do
        stone_1;stone_2;stone_3
        get :index, format: 'json'
      end
      it { expect(response.body).to include("\"global_id\":") }    
    end

  end
  
  describe "GET show", :current => true do
    let(:stone) { FactoryGirl.create(:stone) }
    context "without format" do
      before { get :show, id: stone.id }
      it { expect(assigns(:stone)).to eq stone }
    end

    context "with format 'json'" do
      before { get :show, id: stone.id, format: 'json' }
      it { expect(response.body).to include("\"global_id\":") }    
    end

  end
  
  describe "GET edit" do
    let(:stone) { FactoryGirl.create(:stone) }
    before { get :edit, id: stone.id }
    it { expect(assigns(:stone)).to eq stone }
  end
  
  describe "POST create" do
    let(:attributes) { {name: "stone_name"} }
    it { expect { post :create, stone: attributes }.to change(Stone, :count).by(1) }
    describe "assigns as @stone" do
      before { post :create, stone: attributes }
      it { expect(assigns(:stone)).to be_persisted }
      it { expect(assigns(:stone).name).to eq attributes[:name]}
    end
  end
  
  describe "PUT update" do
    before do
      stone
    end
    let(:stone) { FactoryGirl.create(:stone) }
    let(:attributes) { {name: "update_name"} }
    context "witout format" do
      before { put :update, id: stone.id, stone:attributes }
      it { expect(assigns(:stone)).to eq stone }
      it { expect(assigns(:stone).name).to eq attributes[:name] }
    end
  end

  describe "DELETE destroy" do
    let(:stone) { FactoryGirl.create(:stone) }
    before { stone }
    it { expect { delete :destroy, id: stone.id }.to change(Stone, :count).by(-1) }
  end
  
  describe "GET family" do
    let(:stone) { FactoryGirl.create(:stone) }
    before { get :family, id: stone.id }
    it { expect(assigns(:stone)).to eq stone }
  end
  
  describe "GET picture" do
    let(:stone) { FactoryGirl.create(:stone) }
    before { get :picture, id: stone.id }
    it { expect(assigns(:stone)).to eq stone }
  end
  
  describe "GET map" do
    let(:stone) { FactoryGirl.create(:stone) }
    before { get :map, id: stone.id }
    it { expect(assigns(:stone)).to eq stone }
  end
  
  describe "GET property" do
    let(:stone) { FactoryGirl.create(:stone) }
    before { get :property, id: stone.id }
    it { expect(assigns(:stone)).to eq stone }
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryGirl.create(:stone, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:stone, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:stone, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, ids: ids
    end
    it {expect(assigns(:stones).include?(obj1)).to be_truthy}
    it {expect(assigns(:stones).include?(obj2)).to be_truthy}
    it {expect(assigns(:stones).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3name){"obj3"}
    let(:obj1) { FactoryGirl.create(:stone, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:stone, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:stone, name: obj3name) }
    let(:attributes) { {name: "update_name"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, ids: ids,stone: attributes
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
    after { get :download_card, id: stone.id }
    let(:stone) { FactoryGirl.create(:stone) }
    before do
      stone
      allow(stone).to receive(:build_card).and_return(double(:report))
      allow(double(:report)).to receive(:generate).and_return(double(:generate))
      allow(controller).to receive(:send_data).and_return{controller.render nothing: true}
    end
    it { expect(controller).to receive(:send_data).with(double(:generate), filename: "stone.pdf", type: "application/pdf") }
  end

  describe "GET download_bundle_card" do
    # send_data
  end
  
  # send_data test returns unexpected object.
  pending "GET download_label" do
    after { get :download_label, id: stone.id }
    let(:stone) { FactoryGirl.create(:stone) }
    before do
      stone
      allow(stone).to receive(:build_label).and_return(double(:build_label))
      allow(controller).to receive(:send_data).and_return{controller.render nothing: true}
    end
    it { expect(controller).to receive(:send_data).with(double(:build_label), filename: "Stone_#{stone.id}.csv", type: "text/csv") }
  end
  
  describe "download_bundle_label" do
    after { get :download_bundle_label, ids: params_ids }
    let(:stone) { FactoryGirl.create(:stone) }
    let(:params_ids) { [stone.id.to_s] }
    let(:label) { double(:label) }
    let(:stones) { Stone.all }
    before do
      stone
      allow(Stone).to receive(:where).with(id: params_ids).and_return(stones)
      allow(Stone).to receive(:build_bundle_label).with(stones).and_return(label)
      allow(controller).to receive(:send_data).and_return{controller.render nothing: true}
    end
    it { expect(controller).to receive(:send_data).with(label, filename: "stones.csv", type: "text/csv") }
  end
  
end
