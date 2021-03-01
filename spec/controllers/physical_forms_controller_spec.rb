require 'spec_helper'

describe PhysicalFormsController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:physical_form_1) { FactoryBot.create(:physical_form, name: "hoge") }
    let(:physical_form_2) { FactoryBot.create(:physical_form, name: "physical_form_2") }
    let(:physical_form_3) { FactoryBot.create(:physical_form, name: "physical_form_3") }
    let(:physical_forms){ PhysicalForm.all }
    before do
      physical_form_1;physical_form_2;physical_form_3
      get :index
    end
    it { expect(assigns(:physical_forms).size).to eq physical_forms.size }
  end

  # This "GET show" has no html.
  describe "GET show" do
    let(:physical_form) { FactoryBot.create(:physical_form) }
    before do
      physical_form
      get :show, params: { id: physical_form.id, format: :json }
    end
    it { expect(response.body).to eq(physical_form.to_json) }
  end

  describe "GET edit" do
    let(:physical_form) { FactoryBot.create(:physical_form) }
    before do
      physical_form
      get :edit, params: { id: physical_form.id }
    end
    it { expect(assigns(:physical_form)).to eq physical_form }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "physical_form_name", description: "new descripton"} }
      it { expect { post :create, params: { physical_form: attributes }}.to change(PhysicalForm, :count).by(1) }
      context "assigns a newly created physical_form as @physical_form" do
        before {post :create, params: { physical_form: attributes }}
        it{expect(assigns(:physical_form)).to be_persisted}
        it{expect(assigns(:physical_form).name).to eq(attributes[:name])}
        it{expect(assigns(:physical_form).description).to eq(attributes[:description])}
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow_any_instance_of(PhysicalForm).to receive(:save).and_return(false) }
      it { expect { post :create, params: { physical_form: attributes }}.not_to change(PhysicalForm, :count) }
      context "assigns a newly but unsaved physical_form as @physical_form" do
        before {post :create, params: { physical_form: attributes }}
        it{expect(assigns(:physical_form)).to be_new_record}
        it{expect(assigns(:physical_form).name).to eq(attributes[:name])}
        it{expect(assigns(:physical_form).description).to eq(attributes[:description])}
      end
    end
  end

  describe "PUT update" do
    let(:physical_form) { FactoryBot.create(:physical_form, name: "physical_form", description: "description") }
    before do
      physical_form
      put :update, params: { id: physical_form.id, physical_form: attributes }
    end
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name",description: "update description"} }
      it { expect(assigns(:physical_form)).to eq physical_form }
      it { expect(assigns(:physical_form).name).to eq attributes[:name] }
      it { expect(assigns(:physical_form).description).to eq attributes[:description] }
      it { expect(response).to redirect_to(physical_forms_path) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: "",description: "update description"} }
      before { allow(physical_form).to receive(:update).and_return(false) }
      it { expect(assigns(:physical_form)).to eq physical_form }
      it { expect(assigns(:physical_form).name).to eq attributes[:name] }
      it { expect(assigns(:physical_form).description).to eq attributes[:description] }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    let(:physical_form) { FactoryBot.create(:physical_form, name: "physical_form", description: "description") }
    before{ physical_form }
    it { expect { delete :destroy, params: { id: physical_form.id }}.to change(PhysicalForm, :count).by(-1) }
  end
end
