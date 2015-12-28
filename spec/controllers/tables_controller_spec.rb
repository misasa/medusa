require 'spec_helper'
include ActionDispatch::TestProcess

describe TablesController do
  before { sign_in user }
  let(:user) { FactoryGirl.create(:user) }
  let(:table) { FactoryGirl.create(:table) }

  describe "GET index" do
    before { get :index }
    it { expect(response).to redirect_to(bibs_path) }
  end
  
  describe "GET show" do
    context "format no specify" do
      before { get :show, id: table.id }
      it { expect(assigns(:table)).to eq table }
    end
    context "format csv" do
      before { get :show, id: table.id, format: :csv }
      it { expect(assigns(:table)).to eq table }
      it { expect(response.headers.has_value?("text/csv")).to eq true }
      it do
        flag = response.headers.values.any? {|val| val.include?("filename=\"#{table.caption}.csv\"") }
        expect(flag).to eq true
      end
    end
  end
  
  describe "GET edit" do
    before { get :edit, id: table.id }
    it{ expect(assigns(:table)).to eq table }
  end
  
  describe "PUT update" do
    before do
      table
      put :update, id: table.id, table: attributes
    end
    let(:attributes) { {description: "update_description"} }
    it { expect(assigns(:table)).to eq table }
    it { expect(assigns(:table).description).to eq attributes[:description] }
  end
  
  describe "GET property" do
    before { get :property, id: table.id }
    it { expect(assigns(:table)).to eq table }
  end
  
  describe "DELETE destroy" do
    before { table }
    it { expect { delete :destroy, id: table.id }.to change(Table, :count).by(-1) }
  end

end
