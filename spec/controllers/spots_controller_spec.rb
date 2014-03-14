require 'spec_helper'

describe SpotsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  
  describe "GET edit" do
    let(:spot) { FactoryGirl.create(:spot) }
    before do
      spot
      get :edit, id: spot.id, format: :html
    end
    it { expect(assigns(:spot)).to eq spot }
  end
  
  describe "PUT update" do
    let(:spot) { FactoryGirl.create(:spot, name: "spot") }
    before do
      spot
      put :update, id: spot.id, spot: attributes
    end
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name"} }
      it { expect(assigns(:spot)).to eq spot }
      it { expect(assigns(:spot).name).to eq attributes[:name] }
      it { expect(response).to redirect_to(attachment_file_path(spot.attachment_file)) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {spot_x: nil} }
      before { allow(spot).to receive(:update_attributes).and_return(false) }
      it { expect(assigns(:spot)).to eq spot }
      it { expect(assigns(:spot).spot_x).to eq attributes[:spot_x] }
      it { expect(response).to render_template("edit") }
    end
  end
  
end
