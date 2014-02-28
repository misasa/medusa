require 'spec_helper'

describe AuthorsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  
  describe "GET index" do
    let(:author_1) { FactoryGirl.create(:author, name: "hoge") }
    let(:author_2) { FactoryGirl.create(:author, name: "author_2") }
    let(:author_3) { FactoryGirl.create(:author, name: "author_3") }
    let(:params) { {q: query, page: 2, per_page: 1} }
    before do
      author_1;author_2;author_3
      get :index, params
    end
    context "sort condition is present" do
      let(:query) { {"name_cont" => "author", "s" => "updated_at DESC"} }
      it { expect(assigns(:authors)).to eq [author_2] }
    end
    context "sort condition is nil" do
      let(:query) { {"name_cont" => "author"} }
      it { expect(assigns(:authors)).to eq [author_3] }
    end
  end
  
  # This "GET show" has no html.
  describe "GET show" do
    let(:author) { FactoryGirl.create(:author) }
    before do
      author
      get :show, id: author.id, format: :json
    end
    it { expect(response.body).to eq(author.to_json) }
  end

  describe "GET edit" do
    let(:author) { FactoryGirl.create(:author) }
    before do
      author
      get :edit, id: author.id
    end
    it { expect(assigns(:author)).to eq author }
  end
  
  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "author_name"} }
      it { expect { post :create, author: attributes }.to change(Author, :count).by(1) }
      it "assigns a newly created author as @author" do
        post :create, author: attributes
        expect(assigns(:author)).to be_persisted
        expect(assigns(:author).name).to eq(attributes[:name])
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow_any_instance_of(Author).to receive(:save).and_return(false) }
      it { expect { post :create, author: attributes }.not_to change(Author, :count) }
      it "assigns a newly but unsaved author as @author" do
        post :create, author: attributes
        expect(assigns(:author)).to be_new_record
        expect(assigns(:author).name).to eq(attributes[:name])
      end
    end
  end
  
  describe "PUT update" do
    let(:author) { FactoryGirl.create(:author, name: "author") }
    before do
      author
      put :update, id: author.id, author: attributes
    end
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name"} }
      it { expect(assigns(:author)).to eq author }
      it { expect(assigns(:author).name).to eq attributes[:name] }
      it { expect(response).to redirect_to(authors_path) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow(author).to receive(:update_attributes).and_return(false) }
      it { expect(assigns(:author)).to eq author }
      it { expect(assigns(:author).name).to eq attributes[:name] }
      it { expect(response).to render_template("edit") }
    end
  end
  
end
