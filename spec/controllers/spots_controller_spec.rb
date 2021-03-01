require 'spec_helper'

describe SpotsController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "GET edit" do
    let(:obj) { FactoryBot.create(:spot) }
    before{ get :edit, params: { id: obj.id, format: :html }}
    it { expect(assigns(:spot)).to eq obj }
  end

  describe "PUT update" do
    let(:obj) { FactoryBot.create(:spot, name: "spot") }
    before{ put :update, params: { id: obj.id, spot: attributes }}
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name"} }
      it { expect(assigns(:spot)).to eq obj }
      it { expect(assigns(:spot).name).to eq attributes[:name] }
    end
    describe "with invalid attributes" do
      let(:attributes) { {spot_x: nil} }
      before { allow(obj).to receive(:update).and_return(false) }
      it { expect(assigns(:spot)).to eq obj }
      it { expect(assigns(:spot).spot_x).to eq attributes[:spot_x] }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "GET property" do
    let(:spot) { FactoryBot.create(:spot) }
    before { get :property, params: { id: spot.id }}
    it { expect(assigns(:spot)).to eq spot }
  end

  describe "GET picture" do
    let(:spot) { FactoryBot.create(:spot) }
    before { get :picture, params: { id: spot.id }}
    it { expect(assigns(:spot)).to eq spot }
  end

end
