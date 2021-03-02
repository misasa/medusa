require 'spec_helper'
include ActionDispatch::TestProcess

describe AttachmentFilesController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }
  after { AttachmentFile.destroy_all }
  describe "GET index" do
    let(:attachment_file_1) { FactoryBot.create(:attachment_file, name: "hoge") }
    let(:attachment_file_2) { FactoryBot.create(:attachment_file, name: "attachment_file_2") }
    let(:attachment_file_3) { FactoryBot.create(:attachment_file, name: "attachment_file_3") }
    before do
      attachment_file_1;attachment_file_2;attachment_file_3
      get :index
    end
    it { expect(assigns(:attachment_files).count).to eq 3 }
  end

  describe "GET show" do
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    before { get :show, params: { id: attachment_file.id } }
    it { expect(assigns(:attachment_file)).to eq attachment_file }
  end

  describe "GET show" do
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    before { get :show, params: { id: attachment_file.id, format: 'json'} }
    it { expect(assigns(:attachment_file)).to eq attachment_file }
    it { expect(response.body).to include("\"global_id\":\"#{attachment_file.global_id}\"") }
  end

  describe "GET edit" do
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    before { get :edit, params: { id: attachment_file.id } }
    it { expect(assigns(:attachment_file)).to eq attachment_file }
  end

  describe "GET calibrate", :type => :controller do
    render_views
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    before { get :calibrate, params: { id: attachment_file.id, format: 'modal'} }
    it { expect(assigns(:attachment_file)).to eq attachment_file }
    it { expect(response.body).to have_selector("h4.modal-title") }
  end


  describe "GET edit_affine_matrix", :type => :controller do
    render_views
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    before { get :edit_affine_matrix, params: { id: attachment_file.id, format: 'modal'} }
    it { expect(assigns(:attachment_file)).to eq attachment_file }
    it { expect(response).to render_template("attachment_files/edit_affine_matrix") }
  end

  describe "GET edit_corners", :type => :controller do
    render_views
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    before { get :edit_corners, params: { id: attachment_file.id, format: 'modal'} }
    it { expect(assigns(:attachment_file)).to eq attachment_file }
    it { expect(response).to render_template("attachment_files/edit_corners") }
  end

  describe "POST create" do
    let(:md5hash){ Digest::MD5.hexdigest(File.open("spec/fixtures/files/test_image.jpg", 'rb').read) }
    let(:attributes) { {data: fixture_file_upload("test_image.jpg",'image/jpeg')} }
    it { expect { post :create, params: { attachment_file: attributes, format: 'json' }}.to change(AttachmentFile, :count).by(1) }
    describe "assigns as @attachment_file" do
      before { post :create, params: { attachment_file: attributes, format: 'json' }}
      it { expect(assigns(:attachment_file)).to be_persisted }
      it { expect(assigns(:attachment_file).md5hash).to eq md5hash}
    end
  end


  describe "PUT update", :type => :controller do
    render_views
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    let(:attributes){ { description: 'hello world'  }  }
    before { put :update, params: { id: attachment_file.id, attachment_file: attributes, format: format} }

    context "format json" do
      let(:format){ 'json' }
      it { expect(attachment_file.reload.description).to eq 'hello world' }
      it { expect(response).not_to render_template('attachment_files/update') }
    end

#    context "format js" do
#      let(:format){ 'js' }
#      it { expect(attachment_file.reload.description).to eq 'hello world' }
#      it { expect(response).to render_template('attachment_files/update') }
#    end
  end

  describe "PUT update_affine_matrix", :current => true, :type => :controller do
    render_views
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    let(:format){ 'json' }

    before { put :update_affine_matrix, params: { id: attachment_file.id, affine_matrix: array , format: format} }

    context "with valid values" do
      let(:array){ ["40.5412", "-0.334872", "9192.7", "1.0072", "41.6419", "-2824.46", "0.0", "0.0", "1.0"]  }
      it { expect(attachment_file.reload.affine_matrix).to eq [40.5412, -0.334872, 9192.7, 1.0072, 41.6419, -2824.46, 0.0, 0.0, 1.0] }
      it { expect(response.status).to eq 200 }
      #it { expect(response).to render_template('attachment_files/update_affine_matrix') }
    end

    context "with blank values" do
      let(:array){ ["40.5412", "", "9192.7", "1.0072", "41.6419", "-2824.46", "0.0", "0.0", "1.0"]  }
      it { expect(response.status).to eq 204 }
      #it { expect(response).to render_template('attachment_files/error') }
    end
  end

  describe "PUT update_corners", :current => true, :type => :controller do
    render_views
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    let(:format){ 'json' }
    before { put :update_corners, params: { id: attachment_file.id, corners_on_world: corners, format: format} }

    context "with valid corners" do
      let(:corners){ { "lu" => ["1492.8272", "2371.039"], "ru" => ["1576.2872", "2368.185"], "rb" => ["1573.1728", "2304.961"], "lb" => ["1489.7128", "2307.815"]} }

      it { expect(attachment_file.reload.corners_on_world[0][0]).to be_within(0.01).of(1492.8272) }
      it { expect(response.status).to eq 200 }
    end

    context "with blank" do
      let(:corners){ { "lu" => ["", "2371.039"], "ru" => ["1576.2872", "2368.185"], "rb" => ["1573.1728", "2304.961"], "lb" => ["1489.7128", "2307.815"]} }

      #it { expect(attachment_file.reload.corners_on_world[0][0]).to be_within(0.01).of(1492.8272) }
      #it { expect(response).to render_template('attachment_files/error') }
      it { expect(response.status).to eq 204 }
    end

  end

  describe "GET property" do
    let(:attachment_file) { FactoryBot.create(:attachment_file,name: "test") }
    before do
      attachment_file
      get :property, params: { id: attachment_file.id }
    end
    it {expect(assigns(:attachment_file)).to eq attachment_file}
  end

  describe "GET picture" do
    let(:attachment_file) { FactoryBot.create(:attachment_file,name: "test") }
    before do
      attachment_file
      get :picture, params: { id: attachment_file.id }
    end
    it {expect(assigns(:attachment_file)).to eq attachment_file}
  end

  describe "DELETE destroy" do
  end

  describe "GET download" do
    after { get :download, params: { id: attachment_file.id } }
    let(:attachment_file) { FactoryBot.create(:attachment_file) }
    before do
      attachment_file
      allow(controller).to receive(:send_file){controller.head:no_content}
    end
    it { expect(controller).to receive(:send_file).with(attachment_file.data.path, filename: attachment_file.data_file_name, type: attachment_file.data_content_type) }
  end

  describe "POST bundle_edit" do
    let(:obj1) { FactoryBot.create(:attachment_file, description: "obj1") }
    let(:obj2) { FactoryBot.create(:attachment_file, description: "obj2") }
    let(:obj3) { FactoryBot.create(:attachment_file, description: "obj3") }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_edit, params: { ids: ids }
    end
    it {expect(assigns(:attachment_files).include?(obj1)).to be_truthy}
    it {expect(assigns(:attachment_files).include?(obj2)).to be_truthy}
    it {expect(assigns(:attachment_files).include?(obj3)).to be_falsey}
  end

  describe "POST bundle_update" do
    let(:obj3description){"obj3"}
    #let(:obj3affine){"[]"}
    let(:obj1) { FactoryBot.create(:attachment_file, description: "obj1") }
    let(:obj2) { FactoryBot.create(:attachment_file, description: "obj2") }
    let(:obj3) { FactoryBot.create(:attachment_file, description: obj3description) }
    let(:attributes) { {description: "update_description", affine_matrix_in_string: "[1.00000e+00,0.00000e+00,0.00000e+00;0.00000e+00,1.00000e+00,0.00000e+00;0.00000e+00,0.00000e+00,1.00000e+00]"} }
    let(:ids){[obj1.id,obj2.id]}
    before do
      obj1
      obj2
      obj3
      post :bundle_update, params: { ids: ids,attachment_file: attributes }
      obj1.reload
      obj2.reload
      obj3.reload
    end
    it {expect(obj1.description).to eq attributes[:description]}
    it {expect(obj2.description).to eq attributes[:description]}
    it {expect(obj3.description).to eq obj3description}
    it {expect(obj1.affine_matrix_in_string).to eq attributes[:affine_matrix_in_string]}
    it {expect(obj2.affine_matrix_in_string).to eq attributes[:affine_matrix_in_string]}
    it {expect(obj3.description).to eq obj3description}
  end

end
