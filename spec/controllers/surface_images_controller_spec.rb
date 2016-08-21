require 'spec_helper'

describe SurfaceImagesController do
  let(:parent) { FactoryGirl.create(:surface) }
  let(:child) {FactoryGirl.create(:attachment_file) }
  let(:user) { FactoryGirl.create(:user) }
  let(:url){"where_i_came_from"}
  let(:attributes) { {data: data} }
  let(:data){fixture_file_upload("/files/test_image.jpg",'image/jpeg')}
  before { request.env["HTTP_REFERER"]  = url }
  before { sign_in user }
  before { parent }
  before do
    child
    parent.images << child
  end

  describe "GET show" do
    #let(:method){get :show, surface_id: parent, id: child_id}
    let(:image_1) { FactoryGirl.create(:attachment_file) }
    let(:image_2) { FactoryGirl.create(:attachment_file) }
    before do
      image_1;image_2;
      parent.images << image_1
      parent.images << image_2
    end
    context "without format" do    
      before{get :show,surface_id:parent.id, id: image_2.id }
      it{expect(assigns(:surface)).to eq parent}
      it{expect(assigns(:image)).to eq image_2}      
      it{expect(response).to render_template("show") }
    end
  end

  describe "POST create" do
    let(:method){post :create, surface_id: parent, attachment_file: attributes}
    before{child}
    it { expect{method}.to change(AttachmentFile, :count).by(1) }
    context "validate" do
      before { method }
      it { expect(parent.images.exists?(data_file_name: "test_image.jpg")).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "invalidate" do
      let(:data){nil}
      before { method }
      it { expect {method}.to change(AttachmentFile, :count).by(0) }
      it { expect(parent.images.exists?(data_file_name: "test_image.jpg")).to eq false}
      it { expect(response).to render_template("error")}
    end
  end

  describe "DELETE destory" do
    let(:method){delete :destroy, surface_id: parent, id: child_id}
    before do 
      parent.images << child
    end
    let(:child_id){child.id}
    it { expect {method}.to change(AttachmentFile, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(parent.images.exists?(id: child.id)).to eq false}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"] }
    end
    context "none child" do
      let(:child_id){0}
      it {expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end


  describe "PUT update" do
    let(:method){put :update, surface_id: parent, id: child_id}
    let(:child_id){child.id}
    it { expect {method}.to change(AttachmentFile, :count).by(0) }
    context "present child" do
      before { method }
      it { expect(parent.images.exists?(id: child.id)).to eq true}
    end
    context "none child" do
      let(:child_id){0}
      it { expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end

  describe "POST move_to_tops" do
    let(:method){post :move_to_top, surface_id: parent.id, id: child_id }
    let(:child_1) {FactoryGirl.create(:attachment_file, :name => "child-1") }
    let(:child_2) {FactoryGirl.create(:attachment_file, :name => "child-2") }

    let(:child_id){child_2.id}
    before do
    	parent.images << child
    	parent.images << child_1
    	parent.images << child_2
    end
    context "present child" do
      before { method }
      it { expect(parent.surface_images.order("position ASC").first.image).to eq child_2}
    end
    context "none child" do
      let(:child_id){0}
      it { expect{method}.to raise_error(ActiveRecord::RecordNotFound)}
    end
  end


  describe "POST link_by_global_id" do
    let(:method){post :link_by_global_id, surface_id: parent.id, global_id: global_id }
    context "present child" do
      let(:global_id){child.global_id}
      before { method }
      it { expect(parent.images.exists?(id: child.id)).to eq true}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "none child" do
      let(:global_id){"aaaa"}
      before { method }
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
    context "occur raise" do
      before { allow(AttachmentFile).to receive(:joins).and_raise }
      context "format html" do
        before do
          post :link_by_global_id, surface_id: parent.id, global_id: child.global_id, format: :html
        end
        it { expect(response.body).to render_template("parts/duplicate_global_id") }
        it { expect(response.status).to eq 422 }
      end
      context "format json" do
        before do
          post :link_by_global_id, surface_id: parent.id, global_id: child.global_id, format: :json
        end
        it { expect(response.body).to be_blank }
        it { expect(response.status).to eq 422 }
      end
    end
  end

end
