require 'spec_helper'

describe AttachingsController do
  let(:user) { FactoryBot.create(:user) }
  let(:place1) { FactoryBot.create(:place,name: "place1") }
  let(:place2) { FactoryBot.create(:place,name: "place2") }
  let(:attachment_file1) { FactoryBot.create(:attachment_file,name: "attachment_file1") }
  let(:attachment_file2) { FactoryBot.create(:attachment_file,name: "attachment_file2") }
  let(:attaching1) { FactoryBot.create(:attaching,attachable: place1,attachment_file: attachment_file1) }
  let(:attaching2) { FactoryBot.create(:attaching,attachable: place1,attachment_file: attachment_file2) }
  let(:attaching3) { FactoryBot.create(:attaching,attachable: place2,attachment_file: attachment_file1) }
  before do
    sign_in user
    attaching1
    attaching2
    attaching3
  end


  describe "POST move_to_top" do
    before{request.env["HTTP_REFERER"]  = "where_i_came_from"}
    context "not count change" do
      it { expect { post :move_to_top, params: { id: attaching2.id }}.to change(Attaching, :count).by(0) }
    end

    context " move to top" do
      before do
        post :move_to_top, params: { id: attaching2.id }
        attaching1.reload
        attaching2.reload
      end
      it { expect(attaching1.attachable_id).to eq attaching2.attachable_id}
      it { expect(attaching1.attachable_type).to eq attaching2.attachable_type}
      it { expect(attaching1.position).to eq 2}
      it { expect(attaching2.position).to eq 1}
      it { expect(attaching3.position).to eq 1}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe ".add_tab_param" do
    let(:tabname){"specimen"}
    let(:base_url){"http://wwww.test.co.jp/"}
    before do
      request.env["HTTP_REFERER"]  = url
      post :move_to_top, params: { id: attaching2.id,tab: tab }
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
