require 'spec_helper'

describe "place" do
  before do
    login login_user
    place.attachment_files << attachment_file
    create_data
    visit places_path
  end
  let(:login_user) { FactoryGirl.create(:user) }
  let(:create_data) {}
  
  describe "place detail screen" do
    before { click_link(place.name) }
    let(:create_data) do 
      place.create_record_property(user_id: login_user.id) 
    end
    let(:place) { FactoryGirl.create(:place) }
    let(:attachment_file) { FactoryGirl.create(:attachment_file, data_file_name: "file_name", data_content_type: data_type) }
    
    describe "at-a-glance tab" do
      before { click_link("at-a-glance") }
      describe "pdf icon" do
        context "data_content_type is pdf" do
          let(:data_type) { "application/pdf" }
          it "show icon" do
            expect(page).to have_link("file-#{attachment_file.id}-button")
          end
        end
        context "data_content_type is jpeg" do
          let(:data_type) { "image/jpeg" }
          it "do not show icon" do
            expect(page).not_to have_link("file-#{attachment_file.id}-button")
          end
        end
      end
    end
    
    describe "file tab" do
      before { click_link("file (1)") }
      describe "pdf icon" do
        context "data_content_type is pdf" do
          let(:data_type) { "application/pdf" }
          it "show icon" do
            expect(page).to have_link("file-#{attachment_file.id}-button")
          end
        end
        context "data_content_type is jpeg" do
          let(:data_type) { "image/jpeg" }
          it "do not show icon" do
            expect(page).not_to have_link("file-#{attachment_file.id}-button")
          end
        end
      end
    end
  end
  
end
