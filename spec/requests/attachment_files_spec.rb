require 'spec_helper'

describe "attachment_file" do
  before do
    login login_user
    create_data
    visit attachment_files_path
  end
  let(:login_user) { FactoryGirl.create(:user) }
  let(:create_data) {}
  
  describe "attachment_file list" do
    let(:create_data) { attachment_file.create_record_property(user_id: login_user.id) }
    let(:attachment_file) { FactoryGirl.create(:attachment_file, data_file_name: "file_name", data_content_type: data_content_type) }
    
    context "data_content_type is pdf" do
      let(:data_content_type) { "application/pdf" }
      it "show pdf icon" do
        expect(page).to have_link("file-#{attachment_file.id}-button")
      end
    end
    context "data_content_type is jpeg" do
      let(:data_content_type) { "image/jpeg" }
      it "do not show pdf icon" do
        expect(page).to have_no_link("file-#{attachment_file.id}-button")
      end
    end
  end
  
  describe "attachment_file detail screen" do
    before { click_link(attachment_file.data_file_name) }

    describe "view spot" do
      describe "view spot edit screen" do
        before { visit picture_spot_path(spot.id) }
        let(:create_data) do
          spot
          attachment_file.create_record_property(user_id: login_user.id)
        end
        describe "spot link" do
          let(:spot) { FactoryGirl.create(:spot, attachment_file_id: attachment_file.id, target_uid: target_uid) }
          let(:attachment_file) { FactoryGirl.create(:attachment_file) }
          let(:obj) { FactoryGirl.create(:specimen, name: "obj_name") }
          context "link exists" do
            let(:target_uid) { obj.record_property.global_id }
            it "link name is displayed" do
              expect(page).to have_link(obj.name)
            end
          end
          context "link not exists" do
            let(:target_uid) { "" }
            it "link name is not displayed" do
              expect(page).to have_no_link(obj.name)
            end
          end
        end
      end
    end

    describe "at-a-glance tab" do
      let(:create_data) { attachment_file.create_record_property(user_id: login_user.id) }
      let(:attachment_file) { FactoryGirl.create(:attachment_file, data_file_name: "file_name", data_content_type: data_content_type, original_geometry: "", affine_matrix: []) }
      before { click_link("at-a-glance") }
      describe "pdf icon" do
        context "data_content_type is pdf" do
          let(:data_content_type) { "application/pdf" }
          it "show pdf icon" do
            expect(page).to have_link("file-#{attachment_file.id}-button")
          end
        end
        context "data_content_type is jpeg" do
          let(:data_content_type) { "image/jpeg" }
          it "do not show pdf icon" do
            expect(page).to have_no_link("file-#{attachment_file.id}-button")
          end
        end
      end
    end
  end
  
end
