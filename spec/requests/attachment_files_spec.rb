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
  
  describe "stone detail screen" do
    before { click_link(attachment_file.data_file_name) }
    let(:create_data) { attachment_file.create_record_property(user_id: login_user.id) }
    let(:attachment_file) { FactoryGirl.create(:attachment_file, data_file_name: "file_name", data_content_type: data_content_type, original_geometry: "", affine_matrix: []) }
    describe "at-a-glance tab" do
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
