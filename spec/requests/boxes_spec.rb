require 'spec_helper'

describe "box" do
  before do
    login login_user
    create_data
    visit boxes_path
  end
  let(:login_user) { FactoryGirl.create(:user) }
  let(:create_data) {}
  
  describe "box detail screen" do
    before { click_link(box.name) }
    let(:create_data) do
      box.attachment_files << attachment_file
      box.create_record_property(user_id: login_user.id) 
    end
    let(:box) { FactoryGirl.create(:box) }
    let(:attachment_file) { FactoryGirl.create(:attachment_file, data_file_name: "file_name", data_content_type: data_type) }
    let(:data_type) { "image/jpeg" }

    describe "view spot" do
      context "picture-button is display" do
        before { click_link("picture-button") }
        let(:data_type) { "image/jpeg" }
        it "new spot label is properly displayed" do
          expect(page).to have_content("new spot with link(ID")
          #new spot with link(ID) feildのvalueオプションが存在しないため空であることの検証は行っていない
          expect(page).to have_link("record-property-search")
          expect(page).to have_button("add new spot")
        end
      end
      context "picture-button is not display" do
        context "no attachment_file" do
          let(:create_data) do
            box
            box.create_record_property(user_id: login_user.id)
          end
          it "picture-button not display" do
            expect(page).to have_no_link("picture-button")
          end
          it "new spot label not displayed" do
            expect(page).to have_no_content("new spot with link(ID")
            expect(page).to have_no_link("record-property-search")
            expect(page).to have_no_button("add new spot")
          end
        end
        context "attachment_file is pdf" do
          let(:data_type) { "application/pdf" }
          it "picture-button not display" do
            expect(page).to have_no_link("picture-button")
          end
          it "new spot label not displayed" do
            expect(page).to have_no_content("new spot with link(ID")
            expect(page).to have_no_link("record-property-search")
            expect(page).to have_no_button("add new spot")
          end
        end
      end
      describe "new spot" do
        pending "new spot新規作成時の実装が困難のためpending" do
        end
      end
    end
    
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
