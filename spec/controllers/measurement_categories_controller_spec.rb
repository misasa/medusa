require 'spec_helper'

describe MeasurementCategoriesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:measurement_category_1) { FactoryGirl.create(:measurement_category, name: "hoge") }
    let(:measurement_category_2) { FactoryGirl.create(:measurement_category, name: "measurement_category_2") }
    let(:measurement_category_3) { FactoryGirl.create(:measurement_category, name: "measurement_category_3") }
    let(:measurement_categories){ MeasurementCategory.all }
    before do
      measurement_category_1;measurement_category_2;measurement_category_3
      get :index
    end
    it { expect(assigns(:measurement_categories).size).to eq measurement_categories.size }
  end



  # This "GET show" has no html.
  describe "GET show", :current => true do
    let(:obj) { FactoryGirl.create(:measurement_category) }
    let(:measurement_item_1) { FactoryGirl.create(:measurement_item, nickname: "foo") }
    let(:measurement_item_2) { FactoryGirl.create(:measurement_item, nickname: "bar") }
    before do
      obj 
      obj.measurement_items << measurement_item_1
      obj.measurement_items << measurement_item_2
      get :show, id: obj.id, format: :json
    end
    it { expect(response.body).to eq(obj.to_json) }
    it { expect(response.body).to include("\"measurement_item_ids\":[#{measurement_item_1.id},#{measurement_item_2.id}]") }    
    it { expect(response.body).to include("\"nicknames\":[\"#{measurement_item_1.nickname}\",\"#{measurement_item_2.nickname}\"]") }    
    it { expect(response.body).to include("\"unit_name\":")}
  end

  describe "GET edit" do
    let(:obj) { FactoryGirl.create(:measurement_category) }
    before do
      obj
      get :edit, id: obj.id
    end
    it { expect(assigns(:measurement_category)).to eq obj }
  end

  describe "POST create" do
    describe "with valid attributes" do
      let(:attributes) { {name: "measurement_category_name", description: "new descripton"} }
      it { expect { post :create, measurement_category: attributes }.to change(MeasurementCategory, :count).by(1) }
      context "assigns a newly created measurement_category as @measurement_category" do
        before {post :create, measurement_category: attributes}
        it{expect(assigns(:measurement_category)).to be_persisted}
        it{expect(assigns(:measurement_category).name).to eq(attributes[:name])}
        it{expect(assigns(:measurement_category).description).to eq(attributes[:description])}
      end
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: ""} }
      before { allow_any_instance_of(MeasurementCategory).to receive(:save).and_return(false) }
      it { expect { post :create, measurement_category: attributes }.not_to change(MeasurementCategory, :count) }
      context "assigns a newly but unsaved measurement_category as @measurement_category" do
        before {post :create, measurement_category: attributes}
        it{expect(assigns(:measurement_category)).to be_new_record}
        it{expect(assigns(:measurement_category).name).to eq(attributes[:name])}
        it{expect(assigns(:measurement_category).description).to eq(attributes[:description])}
      end
    end
  end

  describe "PUT update" do
    let(:obj) { FactoryGirl.create(:measurement_category, name: "measurement_category", description: "description") }
    before do
      obj
      put :update, id: obj.id, measurement_category: attributes
    end
    describe "with valid attributes" do
      let(:attributes) { {name: "update_name",description: "update description"} }
      it { expect(assigns(:measurement_category)).to eq obj }
      it { expect(assigns(:measurement_category).name).to eq attributes[:name] }
      it { expect(assigns(:measurement_category).description).to eq attributes[:description] }
      it { expect(response).to redirect_to(measurement_categories_path) }
    end
    describe "with invalid attributes" do
      let(:attributes) { {name: "",description: "update description"} }
      before { allow(obj).to receive(:update_attributes).and_return(false) }
      it { expect(assigns(:measurement_category)).to eq obj }
      it { expect(assigns(:measurement_category).name).to eq attributes[:name] }
      it { expect(assigns(:measurement_category).description).to eq attributes[:description] }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "POST duplicate" do
    let(:obj) { FactoryGirl.create(:measurement_category, name: "aaa",description: "description") }
    let(:measurement_item) { FactoryGirl.create(:measurement_item) }
    before do 
      obj
      obj.measurement_items << measurement_item
    end 
    it { expect { post :duplicate, id: obj.id }.to change(MeasurementCategory, :count).by(1) }
    describe "with invalid attributes" do
      before do
        post :duplicate, id: obj.id
      end
      it { expect(assigns(:measurement_category).name).to eq "aaa duplicate"}
      it { expect(assigns(:measurement_category).description).to eq "description"}
      it { expect(assigns(:measurement_category).measurement_items.count).to eq 1}
      it { expect(assigns(:measurement_category).measurement_items[0]).to eq measurement_item}
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    let(:obj) { FactoryGirl.create(:measurement_category) }
    before{ obj  }
    it { expect { delete :destroy,id: obj.id }.to change(MeasurementCategory, :count).by(-1) }
  end
end
