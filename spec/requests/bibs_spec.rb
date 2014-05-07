require 'spec_helper'

describe "bib master" do
  before do
    login login_user
    create_data
    visit bibs_path
  end
  let(:login_user) { FactoryGirl.create(:user) }
  let(:create_data) {}
  
  describe "bib detail screen" do
    let(:create_data) do
      bib.attachment_files << attachment_file 
      bib.create_record_property(user_id: login_user.id) 
    end
    let(:bib) { FactoryGirl.create(:bib) }
    let(:attachment_file) { FactoryGirl.create(:attachment_file, data_file_name: "file_name", data_content_type: data_type) }
    
    before { click_link(bib.name) }
    
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
