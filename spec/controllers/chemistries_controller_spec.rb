require 'spec_helper'

describe ChemistriesController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "GET edit" do
    let(:obj) { FactoryBot.create(:chemistry) }
    before do
      get :edit, params: { id: obj.id, format: :html }
    end
    it { expect(assigns(:chemistry)).to eq obj }
  end

  describe "PUT update" do
    let(:obj) { FactoryBot.create(:chemistry, description: "chemistry") }
    before do
      put :update, params: { id: obj.id, chemistry: attributes }
    end
    describe "with valid attributes" do
      let(:attributes) { {description: "update_description"} }
      it { expect(assigns(:chemistry)).to eq obj }
      it { expect(assigns(:chemistry).description).to eq attributes[:description] }
      it { expect(response).to redirect_to(analysis_path(obj.analysis)) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {measurement_item_id: nil} }
      before { allow(obj).to receive(:update).and_return(false) }
      it { expect(assigns(:chemistry)).to eq obj }
      it { expect(assigns(:chemistry).measurement_item_id).to eq attributes[:measurement_item_id] }
      it { expect(response).to render_template("edit") }
    end
  end

end
