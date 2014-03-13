require 'spec_helper'
include ActionDispatch::TestProcess

describe PlacesController do
  let(:user) { FactoryGirl.create(:user, :username => "user_1") }
  before { sign_in user }

  describe "GET index" do
    let(:place_1) { FactoryGirl.create(:place, :name => "place_1") }
    let(:place_2) { FactoryGirl.create(:place, :name => "place_2") }
    let(:place_3) { FactoryGirl.create(:place, :name => "hoge") }
    let(:record_property_1) { RecordProperty.find_by(datum_id: place_1.id) }
    let(:record_property_2) { RecordProperty.find_by(datum_id: place_2.id) }
    let(:record_property_3) { RecordProperty.find_by(datum_id: place_3.id) }
    let(:user_2) { FactoryGirl.create(:user, :username => "test_2", :email => "email@test_2.co.jp") }
    let(:user_3) { FactoryGirl.create(:user, :username => "test_3", :email => "email@hoge.co.jp") }
    let(:group_1) { FactoryGirl.create(:group, :name => "group_1") }
    let(:group_2) { FactoryGirl.create(:group, :name => "hoge") }
    let(:group_3) { FactoryGirl.create(:group, :name => "group_3") }
    let(:params) { {q: query} }
    before do
      place_1
      place_2
      place_3
      record_property_1.update_attribute(:group_id, group_1.id)
      record_property_2.update_attributes(:user_id => user_2.id, :group_id => group_2.id, :guest_readable => true, :guest_writable => true)
      record_property_3.update_attributes(:user_id => user_3.id, :group_id => group_3.id, :guest_readable => true, :guest_writable => true)
      get :index, params
    end
    describe "search" do
      context "name search" do
        let(:query) { {"name_cont" => "place"} }
        it { expect(assigns(:places)).to eq [place_2, place_1] }
      end
      context "owner search" do
        let(:query) { {"user_username_cont" => "test"} }
        it { expect(assigns(:places)).to eq [place_3, place_2] }
      end
      context "group search" do
        let(:query) { {"group_name_cont" => "group"} }
        it { expect(assigns(:places)).to eq [place_3, place_1] }
      end
    end
    describe "sort" do
      let(:params) { {q: query, page: 2, per_page: 1} }
      context "sort condition is present" do
        let(:query) { {"name_cont" => "place", "s" => "updated_at DESC"} }
        it { expect(assigns(:places)).to eq [place_1] }
      end
      context "sort condition is nil" do
        let(:query) { {"name_cont" => "place"} }
        it { expect(assigns(:places)).to eq [place_1] }
      end
    end
  end

  # send_data test returns unexpected object.
  describe "GET new" do
  end

  describe "GET show" do
    let(:obj){FactoryGirl.create(:place) }
    before{get :show,id:obj.id}
    it{expect(assigns(:place)).to eq obj}
    it{expect(response).to render_template("show") }
  end

  describe "GET edit" do
  end

  describe "POST create" do
    let(:attributes) { {name: "place_name"} }
    it { expect {post :create ,place: attributes}.to change(Place, :count).by(1) }
    context "create" do
      before{post :create ,place: attributes}
      it{expect(assigns(:place).name).to eq attributes[:name]}
    end
  end

  describe "PUT update" do
    let(:obj){FactoryGirl.create(:place) }
    let(:attributes) { {name: "update_name"} }
    it { expect {put :update ,id: obj.id,place: attributes}.to change(Place, :count).by(0) }
    before do
      obj
      put :update, id: obj.id, place: attributes
    end
    it{expect(assigns(:place).name).to eq attributes[:name]}
  end

  describe "GET map" do
    let(:obj){FactoryGirl.create(:place) }
    before{get :map,id:obj.id}
    it{expect(assigns(:place)).to eq obj}
    it{expect(response).to render_template("map") }
  end

  describe "GET property" do
    let(:obj){FactoryGirl.create(:place) }
    before{get :property,id:obj.id}
    it{expect(assigns(:place)).to eq obj}
    it{expect(response).to render_template("property") }
  end

  describe "POST upload" do
    let(:obj){FactoryGirl.create(:place) }
    let(:data) {fixture_file_upload("/files/test_image.jpg",'image/jpeg') }
    it { expect {post :upload, id: obj.id  ,data: data}.to change(AttachmentFile, :count).by(1) }
    context "" do
      before{post :upload, id: obj.id  ,data: data}
      it{expect(assigns(:place).attachment_files.last.data_file_name).to eq "test_image.jpg"}
    end
  end

  describe "DELETE destroy" do
    let(:obj){FactoryGirl.create(:place) }
    before { obj }
    it { expect{delete :destroy,id: obj.id}.to change(Place, :count).by(-1) }
  end

  describe "POST link_attachment_file_by_global_id" do
    let(:obj){FactoryGirl.create(:place) }
    let(:attachment_file){FactoryGirl.create(:attachment_file) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      attachment_file.record_property.global_id = "test_global_id"
      attachment_file.record_property.save
      post :link_attachment_file_by_global_id,id:obj.id,global_id: attachment_file.global_id
    end
    it {expect(obj.attachment_files[0]).to  eq(attachment_file)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
  end

  describe "POST link_stone_by_global_id" do
    let(:obj){FactoryGirl.create(:place) }
    let(:stone){FactoryGirl.create(:stone) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      stone.record_property.global_id = "test_global_id"
      stone.record_property.save
      post :link_stone_by_global_id,id:obj.id,global_id: stone.global_id
    end
    it { expect(obj.stones[0]).to eq(stone)}
    it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryGirl.create(:place, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:place, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:place, name: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, ids: ids
    end
    it {expect(assigns(:places).include?(obj1)).to be_truthy}
    it {expect(assigns(:places).include?(obj2)).to be_truthy}
    it {expect(assigns(:places).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3name){"obj3"}
    let(:obj1) { FactoryGirl.create(:place, name: "obj1") }
    let(:obj2) { FactoryGirl.create(:place, name: "obj2") }
    let(:obj3) { FactoryGirl.create(:place, name: obj3name) }
    let(:attributes) { {name: "update_name"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, ids: ids,place: attributes
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.name).to eq attributes[:name]}
    it {expect(obj2.name).to eq attributes[:name]}
    it {expect(obj3.name).to eq obj3name}
  end

  describe "POST import" do
    let(:data) { double(:upload_data) }
    context "return raise" do
      before do
        allow(Place).to receive(:import_csv).with(data.to_s).and_raise("error")
        post :import, data: data
      end
      it { expect(response).to render_template("import_invalid") }
    end
    context "return no error" do
      before do
        allow(Place).to receive(:import_csv).with(data.to_s).and_return(import_result)
        post :import, data: data
      end
      context "import success" do
        let(:import_result) { true }
        it { expect(response).to redirect_to(places_path) }
      end
      context "import false" do
        let(:import_result) { false }
        it { expect(response).to render_template("import_invalid") }
      end
    end
  end

end
