require 'spec_helper'

describe UsersController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:user_1) { FactoryGirl.create(:user, username: "hoge",email: "email1@test.co.jp") }
    let(:user_2) { FactoryGirl.create(:user, username: "user_2",email: "email2@test.co.jp") }
    let(:user_3) { FactoryGirl.create(:user, username: "user_3",email: "email3@test.co.jp") }
    let(:users){ User.all }
    before do
      user_1;user_2;user_3
      get :index
    end
    it { expect(assigns(:users).size).to eq users.size }
  end

  # This "GET show" has no html.
  describe "GET show" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      user
      get :show, id: user.id, format: :json
    end
    it { expect(response.body).to eq(user.to_json) }
  end

  describe "GET new" do
    before do
      get :new
    end
    it {expect(assigns(:user)).to be_new_record}
  end

  describe "GET edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      user
      get :edit, id: user.id
    end
    it { expect(assigns(:user)).to eq user }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {username: "user_name", description: "new descripton",email: "mail4@test.co.jp",password: "xxxx",password_confirmation: "xxxx"} }
      it { expect { post :create, user: attributes }.to change(User, :count).by(1) }
      context "assigns a newly created user as @user" do
        before {post :create, user: attributes}
        it{expect(assigns(:user)).to be_persisted}
        it{expect(assigns(:user).username).to eq(attributes[:username])}
        it{expect(assigns(:user).description).to eq(attributes[:description])}
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {username: ""} }
      before { allow_any_instance_of(User).to receive(:save).and_return(false) }
      it { expect { post :create, user: attributes }.not_to change(User, :count) }
      context "assigns a newly but unsaved user as @user" do
        before {post :create, user: attributes}
        it{expect(assigns(:user)).to be_new_record}
        it{expect(assigns(:user).username).to eq(attributes[:username])}
        it{expect(assigns(:user).description).to eq(attributes[:description])}
      end
    end
  end

  describe "PUT update" do
    let(:user) { FactoryGirl.create(:user, username: "user", description: "description") }
    before do
      user
      put :update, id: user.id, user: attributes
    end
    describe "with valid attributes password change " do
      let(:attributes) { {username: "update_name",description: "update description",password: "yyyy",password_confirmation: "yyyy"} }
      it { expect(assigns(:user)).to eq user }
      it { expect(assigns(:user).username).to eq attributes[:username] }
      it { expect(assigns(:user).description).to eq attributes[:description] }
      it { expect(response).to redirect_to(users_path) }
    end
    describe "with valid attributes no password change" do
      let(:attributes) { {username: "update_name",description: "update description",password: "",password_confirmation: ""} }
      it { expect(assigns(:user)).to eq user }
      it { expect(assigns(:user).username).to eq attributes[:username] }
      it { expect(assigns(:user).description).to eq attributes[:description] }
      it { expect(response).to redirect_to(users_path) }
    end
    describe "with invalid attributes no username " do
      let(:attributes) { {username: "",description: "update description"} }
      before { allow(user).to receive(:update_attributes).and_return(false) }
      it { expect(assigns(:user)).to eq user }
      it { expect(assigns(:user).username).to eq attributes[:username] }
      it { expect(assigns(:user).description).to eq attributes[:description] }
      it { expect(response).to render_template("edit") }
    end
  end

end
