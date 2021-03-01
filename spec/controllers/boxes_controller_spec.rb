require 'spec_helper'
include ActionDispatch::TestProcess

describe BoxesController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:box_1) { FactoryBot.create(:box, name: "hoge") }
    let(:box_2) { FactoryBot.create(:box, name: "box_2") }
    let(:box_3) { FactoryBot.create(:box, name: "box_3") }
    let(:specimen_1) { FactoryBot.create(:specimen, name: "hoge", box_id: box_1.id) }
    let(:specimen_2) { FactoryBot.create(:specimen, name: "specimen_2", box_id: box_2.id) }
    let(:specimen_3) { FactoryBot.create(:specimen, name: "specimen_3", box_id: box_3.id) }
    let(:analysis_1) { FactoryBot.create(:analysis, specimen_id: specimen_1.id) }
    let(:analysis_2) { FactoryBot.create(:analysis, specimen_id: specimen_2.id) }
    let(:analysis_3) { FactoryBot.create(:analysis, specimen_id: specimen_3.id) }

    before do
      box_1;box_2;box_3
      specimen_1;specimen_2;specimen_3;
      analysis_1;analysis_2;analysis_3;
    end
    context "without format" do
      before do
        get :index
      end
      it { expect(assigns(:search).class).to eq Ransack::Search }
      it { expect(assigns(:boxes).count).to eq 3 }
    end

    context "with format 'json'" do
      before do
        get :index, format: 'json'
      end
      it { expect(response.body).to include("global_id")}
    end

    context "with format 'pml'" do
      before do
        get :index, format: 'pml'
      end
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_1.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_2.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_3.global_id}") }
    end

  end

  describe "GET show" do
    let(:box) { FactoryBot.create(:box) }
    let(:specimen_1) { FactoryBot.create(:specimen, name: "hoge", box_id: box.id) }
    let(:specimen_2) { FactoryBot.create(:specimen, name: "specimen_2", box_id: box.id) }
    let(:specimen_3) { FactoryBot.create(:specimen, name: "specimen_3", box_id: box.id) }
    let(:analysis_1) { FactoryBot.create(:analysis, specimen_id: specimen_1.id) }
    let(:analysis_2) { FactoryBot.create(:analysis, specimen_id: specimen_2.id) }
    let(:analysis_3) { FactoryBot.create(:analysis, specimen_id: specimen_3.id) }
    before do
      specimen_1;specimen_2;specimen_3;
      analysis_1;analysis_2;analysis_3;
    end
    context "without format" do
      before { get :show, params: { id: box.id }}
      it { expect(assigns(:box)).to eq box }
    end
    context "with format 'json'" do
      before { get :show, params: { id: box.id, format: 'json' }}
      it { expect(response.body).to include("global_id") }
    end
    context "with format 'pml'" do
      before { get :show, params: { id: box.id, format: 'pml' }}
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_1.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_2.global_id}") }
      it { expect(response.body).to include("\<sample_global_id\>#{specimen_3.global_id}") }

    end

    context "without dst_date" do
      let(:ddate) { Date.today}
      let(:dst_date) { ddate.strftime("%Y-%m-%d")}
      it {
        expect(Date).to receive(:today).and_return(ddate)
        get :show, params: { id: box.id, button_action: 'change from 1 day ago' }
        expect(assigns(:dst_date)).to eq dst_date
      }
    end

    context "with dst_date" do
      let(:dst_date) { "2014-12-25"}
      it {
        expect(Date).not_to receive(:today)
        get :show, params: { id: box.id, button_action: 'change from 1 day ago', dst_date: dst_date }
        expect(assigns(:dst_date)).to eq dst_date
      }
    end

    context "with dst_date and src_date" do
      let(:dst_date) { "2014-12-25"}
      let(:src_date) { "2013-12-25"}
      it {
        get :show, params: { id: box.id, button_action: 'change from 1 day ago', dst_date: dst_date, src_date: src_date }
        expect(assigns(:dst_date)).to eq dst_date
        expect(assigns(:src_date)).to eq src_date
      }
    end

    context "with dst_date and from without src_date", :current => true do
      let(:dst_date) { "2014-12-25"}
      let(:src_date) { "2014-12-24"}
      it {
        get :show, params: { id: box.id, button_action: 'xxxx from 1 day ago', dst_date: dst_date }
        expect(assigns(:dst_date)).to eq dst_date
        expect(assigns(:src_date)).to eq src_date
      }
    end

    context "without dst_date and src_date", :current => true do
      let(:ddate) { Date.today }
      let(:dst_date) { ddate.strftime("%Y-%m-%d")}
      let(:src_date) { ddate.years_ago(10).strftime("%Y-%m-%d") }
      it {
        expect(Date).to receive(:today).and_return(ddate)
        Path.stub_chain(:order, :first).and_return(double("path", brought_in_at: ddate.years_ago(10) ))
        #allow(Path).to receive(:first).and_return(double("path"))
        get :show, params: { id: box.id }
        expect(assigns(:dst_date)).to eq dst_date
        expect(assigns(:src_date)).to eq src_date
      }
    end

    context "with button_action change from" do
      let(:ddate) { Date.today}
      let(:dst_date) { ddate.strftime("%Y-%m-%d")}
      let(:a_day_ago) { ddate.days_ago(1).strftime("%Y-%m-%d")}
      let(:relation) { double("activerecord-relation")}
      let(:contents_search) { double("ransack") }

      context "without sorts" do

        before {
          allow(relation).to receive(:ransack).and_return(contents_search.as_null_object)
          allow(Path).to receive(:change).and_return(relation)
        }
        it {
          expect(contents_search).to receive(:sorts=).with(['brought_at DESC', 'sign ASC'])
          get :show, params: { id: box.id, button_action: 'change from 1 day ago', dst_date: dst_date }
        }
      end

      context "with sorts" do
        before {
          allow(Path).to receive(:change).and_return(relation)
        }
        it {
          expect(relation).to receive(:ransack).with({"s" => "brought_in_at+asc"}).and_return(contents_search.as_null_object)
          expect(contents_search).to receive(:sorts).and_return("brought_in_at ASC")
          expect(contents_search).not_to receive(:sorts=)
          get :show, params: { id: box.id, button_action: 'change from 1 day ago', dst_date: dst_date, q: {s: 'brought_in_at+asc'}}
        }
      end

    end

    context "with button_action integ from" do
      let(:ddate) { Date.today}
      let(:dst_date) { ddate.strftime("%Y-%m-%d")}
      let(:a_day_ago) { ddate.days_ago(1).strftime("%Y-%m-%d")}
      let(:relation) { double("activerecord-relation")}
      let(:contents_search) { double("ransack") }

      context "without sorts" do

        before {
          allow(relation).to receive(:ransack).and_return(contents_search.as_null_object)
          allow(Path).to receive(:integ).and_return(relation)
        }
        it {
          expect(contents_search).to receive(:sorts=).with('path ASC')
          get :show, params: { id: box.id, button_action: 'integ from 1 day ago', dst_date: dst_date }
        }
      end

      context "with sorts" do
        before {
          allow(Path).to receive(:integ).and_return(relation)
        }
        it {
          expect(relation).to receive(:ransack).with({"s" => "brought_in_at+asc"}).and_return(contents_search.as_null_object)
          expect(contents_search).to receive(:sorts).and_return("brought_in_at ASC")
          expect(contents_search).not_to receive(:sorts=)
          get :show, params: { id: box.id, button_action: 'integ from 1 day ago', dst_date: dst_date, q: {s: 'brought_in_at+asc'}}
        }
      end

    end


    context "with button_action snapshot", :current => true do
      let(:ddate) { Date.today}
      let(:dst_date) { ddate.strftime("%Y-%m-%d")}
      let(:dst_date_time){ Time.zone.now }
      let(:a_day_ago) { ddate.days_ago(1).strftime("%Y-%m-%d")}
      let(:relation) { double("activerecord-relation")}
      let(:contents_search) { double("ransack") }

      context "without sorts" do

        before {
          #allow(Time).to receive_message_chain(:zone, :now).and_return(dst_date_time)
          allow(relation).to receive(:ransack).and_return(contents_search.as_null_object)
          allow(Path).to receive(:snapshot).and_return(relation)
        }
        it {
          expect(contents_search).to receive(:sorts=).with('path ASC')
          get :show, params: { id: box.id, button_action: 'snapshot', dst_date: dst_date }
        }
      end

      context "with sorts" do
        before {
          #allow(Time).to receive_message_chain(:zone, :now).and_return(dst_date_time)
          allow(relation).to receive(:search).and_return(contents_search.as_null_object)
          allow(Path).to receive(:snapshot).and_return(relation)
        }


        it {
          #expect(Path).to receive(:snapshot).with(box, dst_date).and_return(relation)
          expect(relation).to receive(:ransack).with({"s" => "brought_in_at+asc"}).and_return(contents_search.as_null_object)
          expect(contents_search).to receive(:sorts).and_return("brought_in_at ASC")
          expect(contents_search).not_to receive(:sorts=)
          get :show, params: { id: box.id, button_action: 'snapshot', dst_date: dst_date, q: {s: 'brought_in_at+asc'}}
        }
      end

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
      let(:relation) { double("activerecord-relation")}
      let(:relation_2) { double("activerecord-relation")}
      let(:contents_search) { double("ransack") }

      # before do
      #     allow(relation).to receive(:ransack).and_return(contents_search)
      #     allow(Path).to receive(:diff).and_return(relation)
      # end

      context "without sorts" do
        before {
          allow(relation).to receive(:ransack).and_return(contents_search.as_null_object)
          allow(Path).to receive(:diff).and_return(relation)
        }
        it {
          expect(contents_search).to receive(:sorts=).with('path ASC')
          get :show, params: { id: box.id, button_action: 'diff from 1 day ago', dst_date: dst_date }
        }
      end

      context "with sorts" do
        before {
          allow(Path).to receive(:diff).and_return(relation)
        }
        it {
          expect(relation).to receive(:ransack).with({"s" => "brought_in_at+asc"}).and_return(contents_search.as_null_object)
          expect(contents_search).to receive(:sorts).and_return("brought_in_at ASC")
          expect(contents_search).not_to receive(:sorts=)
          get :show, params: { id: box.id, button_action: 'diff from 1 day ago', dst_date: dst_date, q: {s: 'brought_in_at+asc'}}
        }
      end

      context "1 day ago" do
        before {
          get :show, params: { id: box.id, button_action: 'diff from 1 day ago', dst_date: dst_date }
        }
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq a_day_ago }
      end

      context "2 days ago" do
        before { get :show, params: { id: box.id, button_action: 'diff from 2 days ago', dst_date: dst_date }}
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq two_days_ago }
      end

      context "1 week ago" do
        before { get :show, params: { id: box.id, button_action: 'diff from 1 week ago', dst_date: dst_date }}
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq one_week_ago }
      end

      context "2 weeks ago" do
        before { get :show, params: { id: box.id, button_action: 'diff from 2 weeks ago', dst_date: dst_date }}
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq two_weeks_ago }
      end

      context "1 month ago" do
        before { get :show, params: { id: box.id, button_action: 'diff from 1 month ago', dst_date: dst_date }}
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq one_month_ago }
      end

      context "2 months ago" do
        before { get :show, params: { id: box.id, button_action: 'diff from 2 months ago', dst_date: dst_date }}
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq two_months_ago }
      end

      context "1 year ago" do
        before { get :show, params: { id: box.id, button_action: 'diff from 1 year ago', dst_date: dst_date }}
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq one_year_ago }
      end

      context "2 years ago" do
        before { get :show, params: { id: box.id, button_action: 'diff from 2 years ago', dst_date: dst_date }}
        it { expect(assigns(:dst_date)).to eq dst_date }
        it { expect(assigns(:src_date)).to eq two_years_ago }
      end

    end

  end

  describe "GET edit" do
    let(:box) { FactoryBot.create(:box) }
    before { get :edit, params: { id: box.id }}
    it { expect(assigns(:box)).to eq box }
  end

  describe "POST create" do
    let(:attributes) { {name: "box_name"} }
    it { expect { post :create, params: { box: attributes }}.to change(Box, :count).by(1) }
    describe "assigns as @box" do
      before { post :create, params: { box: attributes }}
      it { expect(assigns(:box)).to be_persisted }
      it { expect(assigns(:box).name).to eq attributes[:name]}
    end
  end

  describe "PUT update" do
    before do
      box
      put :update, params: { id: box.id, box: attributes }
    end
    let(:box) { FactoryBot.create(:box) }

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
    let(:box) { FactoryBot.create(:box) }
    before { box }
    it { expect { delete :destroy, params: { id: box.id }}.to change(Box, :count).by(-1) }
  end

  describe "GET family" do
    let(:box) { FactoryBot.create(:box) }
    before { get :family, params: { id: box.id }}
    it { expect(assigns(:box)).to eq box }
  end

  describe "GET picture" do
    let(:box) { FactoryBot.create(:box) }
    before { get :picture, params: { id: box.id }}
    it { expect(assigns(:box)).to eq box }
  end

  describe "GET property" do
    let(:box) { FactoryBot.create(:box) }
    before { get :property, params: { id: box.id }}
    it { expect(assigns(:box)).to eq box }
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryBot.create(:box, name: "obj1") }
    let(:obj2) { FactoryBot.create(:box, name: "obj2") }
    let(:obj3) { FactoryBot.create(:box, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, params: { ids: ids }
    end
    it {expect(assigns(:boxes).include?(obj1)).to be_truthy}
    it {expect(assigns(:boxes).include?(obj2)).to be_truthy}
    it {expect(assigns(:boxes).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3path){"obj3"}
    let(:obj1) { FactoryBot.create(:box, path: "obj1") }
    let(:obj2) { FactoryBot.create(:box, path: "obj2") }
    let(:obj3) { FactoryBot.create(:box, path: obj3path) }
    let(:attributes) { {path: "update_path"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, params: { ids: ids,box: attributes }
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.path).to eq attributes[:path]}
    it {expect(obj2.path).to eq attributes[:path]}
    it {expect(obj3.path).to eq obj3path}
  end

end
