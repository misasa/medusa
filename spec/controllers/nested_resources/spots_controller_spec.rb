require 'spec_helper'

describe NestedResources::SpotsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "POST create" do
    let(:parent) { FactoryGirl.create(:attachment_file) }
    let(:attributes) { {spot_x: spot_x,spot_y: 0} }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
    end
    context "validate" do
      let(:spot_x){1}
      it { expect {post :create, parent_resource: :attachment_file, attachment_file_id: parent, spot: attributes}.to change(Spot, :count).by(1) }
      context "parent attachment_file" do
        before { post :create, parent_resource: :attachment_file, attachment_file_id: parent, spot: attributes }
        it { expect(parent.spots.last.spot_x).to eq attributes[:spot_x]}
        it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
      end
    end
    context "invalidate" do
      let(:spot_x){nil}
      it { expect {post :create, parent_resource: :attachment_file, attachment_file_id: parent, spot: attributes}.to change(Spot, :count).by(0) }
      context "parent attachment_file" do
        before { post :create, parent_resource: :attachment_file, attachment_file_id: parent, spot: attributes }
        it { expect(response).to render_template("error")}
      end
    end
  end

  describe "DELETE destory" do
    let(:parent){FactoryGirl.create(:attachment_file) }
    let(:child){FactoryGirl.create(:spot)}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      parent.spots << child
    end
    it  {expect {delete :destroy, attachment_file_id: parent,id: child.id}.to change(Spot, :count).by(-1)}
    context "parent attachment_file" do
      before {delete :destroy, attachment_file_id: parent, id: child.id}
      it {expect(parent.spots.exists?(id: child.id)).to be false}
      it {expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe ".add_tab_param" do
    let(:tabname){"spot"}
    let(:parent){FactoryGirl.create(:attachment_file) }
    let(:child){FactoryGirl.create(:spot) }
    let(:base_url){"http://wwww.test.co.jp/"}
    before do
      request.env["HTTP_REFERER"]  = url
      delete :destroy, attachment_file_id: parent, id: child.id, tab: tab
    end
    context "add none param" do
      let(:tab){""}
      let(:url){base_url}
      it { expect(response).to redirect_to base_url}
    end
    context "add param" do
      let(:tab){tabname}
      context "1st param" do
        let(:url){base_url}
        it { expect(response).to redirect_to base_url + "?tab=" + tabname}
      end
      context "2nd param" do
        let(:url){base_url + "?aaa=aaa"}
        it { expect(response).to redirect_to base_url + "?aaa=aaa&tab=" + tabname}
      end
      context "exsist tab param other param" do
        let(:url){base_url + "?tab=aaa&aaa=aaa"}
        it { expect(response).to redirect_to base_url + "?aaa=aaa&tab=" + tabname}
      end
      context "exsist tab param other none param" do
        let(:url){base_url + "?tab=aaa"}
        it { expect(response).to redirect_to base_url + "?tab=" + tabname}
      end
    end
  end

end
