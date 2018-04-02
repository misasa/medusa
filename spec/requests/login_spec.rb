require 'spec_helper'

describe "with autologin", :current => true do
  before do
    allow(Settings).to receive(:autologin).and_return(user_1.username)
    #login user_1
    create_data
    visit records_path

  end
  let(:user_1) { FactoryGirl.create(:user) }
  let(:create_data) {}
  
  describe "records list" do
    let(:create_data) do 
      attachment_file.create_record_property(user_id: user_1.id)
      specimen.create_record_property(user_id: user_1.id)
    end
    let(:attachment_file) { FactoryGirl.create(:attachment_file, data_file_name: "file_name", data_content_type: "application/pdf") }
    let(:specimen){ FactoryGirl.create(:specimen) }
    context "with Config.autologin" do
      it "show link to records" do
        expect(page).to have_link(nil, :href => attachment_files_path(@attachment_file))
        expect(page).to have_link(nil, :href => attachment_files_path(@specimen))
      end
    end
  end
    
end
