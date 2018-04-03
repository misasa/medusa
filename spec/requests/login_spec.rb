require 'spec_helper'

describe "get pmlame.json with autologin" do
  before do
    user_1
    user_2
    allow(Settings).to receive(:autologin).and_return(user_2.username)
    create_data
    #login user_1
    get "/records/#{specimen.global_id}/pmlame.json", format: 'json'
  end
  let(:user_1) { FactoryGirl.create(:user, username: "user_1", email: "user_1@example.com") }
  let(:user_2) { FactoryGirl.create(:user, username: "user_2", email: "user_2@example.com") }
  let(:create_data) {}
  describe "records list" do
    let(:create_data) do 
      attachment_file.create_record_property(user_id: user_1.id)
      specimen.create_record_property(user_id: user_1.id)
      analysis.create_record_property(user_id: user_1.id)
    end
    let(:attachment_file) { FactoryGirl.create(:attachment_file, data_file_name: "file_name", data_content_type: "application/pdf") }
    let(:specimen){ FactoryGirl.create(:specimen) }
    let(:analysis){ FactoryGirl.create(:analysis, specimen_id: specimen.id) }
    context "with Config.autologin" do
      before do
        #puts response
        #puts response.body
        puts response.body
      end
      it "show link to records" do
        expect(response).to be_success
        expect(JSON.parse(response.body)).to be_a_kind_of(Array)
        #expect(JSON.parse(response.body)[0]['id']).to eq(specimen.id)
        #expect(page).to have_link(nil, :href => attachment_files_path(@attachment_file))
        #expect(page).to have_link(nil, :href => attachment_files_path(@specimen))
      end
    end
  end

end

describe "with autologin" do
  before do
    allow(Settings).to receive(:autologin).and_return(user_1.username)
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
