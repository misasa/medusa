require 'spec_helper'

describe MeasurementItemsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:measurement_item_1) { FactoryGirl.create(:measurement_item, nickname: "hoge") }
    let(:measurement_item_2) { FactoryGirl.create(:measurement_item, nickname: "measurement_item_2") }
    let(:measurement_item_3) { FactoryGirl.create(:measurement_item, nickname: "measurement_item_3") }
    let(:measurement_items){ MeasurementItem.all }
    before do
      measurement_item_1;measurement_item_2;measurement_item_3
      get :index
    end
    it { expect(assigns(:measurement_items).size).to eq measurement_items.size }
  end

  # This "GET show" has no html.
  describe "GET show" do
    let(:measurement_item) { FactoryGirl.create(:measurement_item) }
    before do
      measurement_item
      get :show, id: measurement_item.id, format: :json
    end
    it { expect(response.body).to eq(measurement_item.to_json) }
  end

  describe "GET edit" do
    let(:measurement_item) { FactoryGirl.create(:measurement_item) }
    before do
      measurement_item
      get :edit, id: measurement_item.id
    end
    it { expect(assigns(:measurement_item)).to eq measurement_item }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {nickname: "measurement_item_nickname", description: "new descripton"} }
      it { expect { post :create, measurement_item: attributes }.to change(MeasurementItem, :count).by(1) }
      context "assigns a newly created measurement_item as @measurement_item" do
        before {post :create, measurement_item: attributes}
        it{expect(assigns(:measurement_item)).to be_persisted}
        it{expect(assigns(:measurement_item).nickname).to eq(attributes[:nickname])}
        it{expect(assigns(:measurement_item).description).to eq(attributes[:description])}
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {nickname: ""} }
      before { allow_any_instance_of(MeasurementItem).to receive(:save).and_return(false) }
      it { expect { post :create, measurement_item: attributes }.not_to change(MeasurementItem, :count) }
      context "assigns a newly but unsaved measurement_item as @measurement_item" do
        before {post :create, measurement_item: attributes}
        it{expect(assigns(:measurement_item)).to be_new_record}
        it{expect(assigns(:measurement_item).nickname).to eq(attributes[:nickname])}
        it{expect(assigns(:measurement_item).description).to eq(attributes[:description])}
      end
    end
  end

  describe "PUT update" do
    let(:measurement_item) { FactoryGirl.create(:measurement_item, nickname: "measurement_item", description: "description") }
    before do
      measurement_item
      put :update, id: measurement_item.id, measurement_item: attributes
    end
    describe "with valid attributes" do
      let(:attributes) { {nickname: "update_nickname",description: "update description"} }
      it { expect(assigns(:measurement_item)).to eq measurement_item }
      it { expect(assigns(:measurement_item).nickname).to eq attributes[:nickname] }
      it { expect(assigns(:measurement_item).description).to eq attributes[:description] }
      it { expect(response).to redirect_to(measurement_items_path) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {nickname: "",description: "update description"} }
      before { allow(measurement_item).to receive(:update_attributes).and_return(false) }
      it { expect(assigns(:measurement_item)).to eq measurement_item }
      it { expect(assigns(:measurement_item).nickname).to eq attributes[:nickname] }
      it { expect(assigns(:measurement_item).description).to eq attributes[:description] }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    let(:measurement_item) { FactoryGirl.create(:measurement_item, nickname: "measurement_item", description: "description") }
    before{ measurement_item }
    it { expect { delete :destroy,id: measurement_item.id }.to change(MeasurementItem, :count).by(-1) }
  end
end
