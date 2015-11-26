require 'spec_helper'
include ActionDispatch::TestProcess

describe BoxesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:box_1) { FactoryGirl.create(:box, name: "hoge") }
    let(:box_2) { FactoryGirl.create(:box, name: "box_2") }
    let(:box_3) { FactoryGirl.create(:box, name: "box_3") }
    let(:stone_1) { FactoryGirl.create(:stone, name: "hoge", box_id: box_1.id) }
    let(:stone_2) { FactoryGirl.create(:stone, name: "stone_2", box_id: box_2.id) }
    let(:stone_3) { FactoryGirl.create(:stone, name: "stone_3", box_id: box_3.id) }
    let(:analysis_1) { FactoryGirl.create(:analysis, stone_id: stone_1.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, stone_id: stone_2.id) }
    let(:analysis_3) { FactoryGirl.create(:analysis, stone_id: stone_3.id) }

    before do
      box_1;box_2;box_3
      stone_1;stone_2;stone_3;      
      analysis_1;analysis_2;analysis_3;
    end
    context "without format" do
      before do
        get :index
      end
      it { expect(assigns(:search).class).to eq Ransack::Search }
      it { expect(assigns(:boxes).count).to eq 3 }
    end

    context "with format 'json'", :current => true do
      before do
        get :index, format: 'json'
      end
      it { expect(response.body).to include("global_id")}
    end

    context "with format 'pml'", :current => true do
      before do
        get :index, format: 'pml'
      end
      it { expect(response.body).to include("\<sample_global_id\>#{stone_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{stone_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{stone_3.global_id}") }    
    end

  end

  describe "GET show", :current => true do
    let(:box) { FactoryGirl.create(:box) }
    let(:stone_1) { FactoryGirl.create(:stone, name: "hoge", box_id: box.id) }
    let(:stone_2) { FactoryGirl.create(:stone, name: "stone_2", box_id: box.id) }
    let(:stone_3) { FactoryGirl.create(:stone, name: "stone_3", box_id: box.id) }
    let(:analysis_1) { FactoryGirl.create(:analysis, stone_id: stone_1.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, stone_id: stone_2.id) }
    let(:analysis_3) { FactoryGirl.create(:analysis, stone_id: stone_3.id) }
    before do
      stone_1;stone_2;stone_3;      
      analysis_1;analysis_2;analysis_3;
    end
    context "without format" do
      before { get :show, id: box.id }
      it { expect(assigns(:box)).to eq box }
    end
    context "with format 'json'", :current => true do
      before { get :show, id: box.id, format: 'json' }
      it { expect(response.body).to include("global_id") }
    end
    context "with format 'pml'", :current => true do
      before { get :show, id: box.id, format: 'pml' }
      it { expect(response.body).to include("\<sample_global_id\>#{stone_1.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{stone_2.global_id}") }    
      it { expect(response.body).to include("\<sample_global_id\>#{stone_3.global_id}") }    

    end

    context "with button_action difference from" do
      let(:ddate) { Date.today}
      let(:dst_date) { ddate.strftime("%Y-%m-%d")}
      let(:a_day_ago) { ddate.days_ago(1).strftime("%Y-%m-%d")}
      let(:two_days_ago) { ddate.days_ago(2).strftime("%Y-%m-%d")}
      let(:one_week_ago) { ddate.weeks_ago(1).strftime("%Y-%m-%d")}
      let(:two_weeks_ago) { ddate.weeks_ago(2).strftime("%Y-%m-%d")}
      let(:one_month_ago) { ddate.months_ago(1).strftime("%Y-%m-%d")}
      let(:two_months_ago) { ddate.months_ago(2).strftime("%Y-%m-%d")}
      let(:one_year_ago) { ddate.years_ago(1).strftime("%Y-%m-%d")}
      let(:two_years_ago) { ddate.years_ago(2).strftime("%Y-%m-%d")}

      context "1 day ago" do
        before { get :show, id: box.id, button_action: 'difference from 1 day ago', dst_date: dst_date }
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq a_day_ago }
      end

      context "2 days ago" do
        before { get :show, id: box.id, button_action: 'difference from 2 days ago', dst_date: dst_date }
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq two_days_ago }
      end

      context "1 week ago" do
        before { get :show, id: box.id, button_action: 'difference from 1 week ago', dst_date: dst_date }
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq one_week_ago }
      end

      context "2 weeks ago" do
        before { get :show, id: box.id, button_action: 'difference from 2 weeks ago', dst_date: dst_date }
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq two_weeks_ago }
      end

      context "1 month ago" do
        before { get :show, id: box.id, button_action: 'difference from 1 month ago', dst_date: dst_date }
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq one_month_ago }
      end

      context "2 months ago" do
        before { get :show, id: box.id, button_action: 'difference from 2 months ago', dst_date: dst_date }
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq two_months_ago }
      end

      context "1 year ago" do
        before { get :show, id: box.id, button_action: 'difference from 1 year ago', dst_date: dst_date }
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq one_year_ago }
      end

      context "2 years ago" do
        before { get :show, id: box.id, button_action: 'difference from 2 years ago', dst_date: dst_date }
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq two_years_ago }
      end

    end

  end

  describe "GET edit" do
    let(:box) { FactoryGirl.create(:box) }
    before { get :edit, id: box.id }
    it { expect(assigns(:box)).to eq box }
  end

  describe "POST create" do
    let(:attributes) { {name: "box_name"} }
    it { expect { post :create, box: attributes }.to change(Box, :count).by(1) }
    describe "assigns as @box" do
      before { post :create, box: attributes }
      it { expect(assigns(:box)).to be_persisted }
      it { expect(assigns(:box).name).to eq attributes[:name]}
    end
  end

  describe "PUT update", :current => true do
    before do
      box
      put :update, id: box.id, box: attributes
    end
    let(:box) { FactoryGirl.create(:box) }

    context "name" do
      let(:attributes) { {name: "update_name", parent_id: "11"} }
      it { expect(assigns(:box)).to eq box }
      it { expect(assigns(:box).name).to eq attributes[:name] }
    end

    context "parent_id" do
      let(:attributes) { {name: "box_1", parent_id: 11} }
      it { expect(assigns(:box)).to eq box }
      #it { expect(assigns(:box).name).to eq attributes[:name] }
      it { expect(assigns(:box).parent_id).to eq attributes[:parent_id] }      
    end


  end

  describe "DELETE destroy" do
    let(:box) { FactoryGirl.create(:box) }
    before { box }
    it { expect { delete :destroy, id: box.id }.to change(Box, :count).by(-1) }
  end

  describe "GET family" do
    let(:box) { FactoryGirl.create(:box) }
    before { get :family, id: box.id }
    it { expect(assigns(:box)).to eq box }
  end

  describe "GET picture" do
    let(:box) { FactoryGirl.create(:box) }
    before { get :picture, id: box.id }
    it { expect(assigns(:box)).to eq box }
  end

  describe "GET property" do
    let(:box) { FactoryGirl.create(:box) }
    before { get :property, id: box.id }
    it { expect(assigns(:box)).to eq box }
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryGirl.create(:box, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:box, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:box, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, ids: ids
    end
    it {expect(assigns(:boxes).include?(obj1)).to be_truthy}
    it {expect(assigns(:boxes).include?(obj2)).to be_truthy}
    it {expect(assigns(:boxes).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3path){"obj3"}
    let(:obj1) { FactoryGirl.create(:box, path: "obj1") }
    let(:obj2) { FactoryGirl.create(:box, path: "obj2") }
    let(:obj3) { FactoryGirl.create(:box, path: obj3path) }
    let(:attributes) { {path: "update_path"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, ids: ids,box: attributes
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.path).to eq attributes[:path]}
    it {expect(obj2.path).to eq attributes[:path]}
    it {expect(obj3.path).to eq obj3path}
  end

end
