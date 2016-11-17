require 'spec_helper'
include ActionDispatch::TestProcess

describe SearchColumnsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let!(:column1) { FactoryGirl.create(:search_column, user: user, datum_type: "Specimen", display_order: 1, display_type: 0) }
    let!(:column2) { FactoryGirl.create(:search_column, user: user, datum_type: "Specimen", display_order: 2, display_type: 1) }
    let!(:column3) { FactoryGirl.create(:search_column, user: user, datum_type: "Specimen", display_order: 3, display_type: 2) }
    let!(:column4) { FactoryGirl.create(:search_column, user: user, datum_type: "Box", display_order: 3, display_type: 2) }
    let!(:column5) { FactoryGirl.create(:search_column, user_id: 0, datum_type: "Specimen", display_order: 4, display_type: 0) }
    before { get :index }
    it { expect(assigns(:search_columns)).to eq [column1, column2, column3] }
    it { expect(response).to render_template(layout: :application) }
  end

  describe "POST update_order" do
    let!(:column1) { FactoryGirl.create(:search_column, user: user, datum_type: "Specimen", display_order: 1, display_type: 0) }
    let!(:column2) { FactoryGirl.create(:search_column, user: user, datum_type: "Specimen", display_order: 2, display_type: 1) }
    let!(:column3) { FactoryGirl.create(:search_column, user: user, datum_type: "Specimen", display_order: 3, display_type: 2) }
    let(:params) { { "display_types" => { column3.id.to_s => "1", column2.id.to_s => "0", column1.id.to_s => "2" } } }
    subject { post :update_order, params }
    it { expect{ subject }.to change{ column1.reload.display_order }.from(1).to(3) }
    it { expect{ subject }.to_not change{ column2.reload.display_order } }
    it { expect{ subject }.to change{ column3.reload.display_order }.from(3).to(1) }
    it { expect{ subject }.to change{ column1.reload.display_type }.from(0).to(2) }
    it { expect{ subject }.to change{ column2.reload.display_type }.from(1).to(0) }
    it { expect{ subject }.to change{ column3.reload.display_type }.from(2).to(1) }
  end

  describe "GET master_index" do
    let!(:column1) { FactoryGirl.create(:search_column, user_id: 0, datum_type: "Specimen", display_order: 1, display_type: 0) }
    let!(:column2) { FactoryGirl.create(:search_column, user_id: 0, datum_type: "Specimen", display_order: 2, display_type: 1) }
    let!(:column3) { FactoryGirl.create(:search_column, user_id: 0, datum_type: "Specimen", display_order: 3, display_type: 2) }
    let!(:column4) { FactoryGirl.create(:search_column, user_id: 0, datum_type: "Box", display_order: 3, display_type: 2) }
    let!(:column5) { FactoryGirl.create(:search_column, user: user, datum_type: "Specimen", display_order: 4, display_type: 0) }
    before { get :master_index }
    it { expect(assigns(:search_columns)).to eq [column1, column2, column3] }
    it { expect(response).to render_template(layout: :admin) }
  end

  describe "POST master_update_order" do
    let!(:column1) { FactoryGirl.create(:search_column, user_id: 0, datum_type: "Specimen", display_order: 1, display_type: 0) }
    let!(:column2) { FactoryGirl.create(:search_column, user_id: 0, datum_type: "Specimen", display_order: 2, display_type: 1) }
    let!(:column3) { FactoryGirl.create(:search_column, user_id: 0, datum_type: "Specimen", display_order: 3, display_type: 2) }
    let(:params) { { "display_types" => { column3.id.to_s => "1", column2.id.to_s => "0", column1.id.to_s => "2" } } }
    subject { post :master_update_order, params }
    it { expect{ subject }.to change{ column1.reload.display_order }.from(1).to(3) }
    it { expect{ subject }.to_not change{ column2.reload.display_order } }
    it { expect{ subject }.to change{ column3.reload.display_order }.from(3).to(1) }
    it { expect{ subject }.to change{ column1.reload.display_type }.from(0).to(2) }
    it { expect{ subject }.to change{ column2.reload.display_type }.from(1).to(0) }
    it { expect{ subject }.to change{ column3.reload.display_type }.from(2).to(1) }
  end
end
