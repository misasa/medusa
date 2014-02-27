require "spec_helper"
include ActionDispatch::TestProcess

describe AttachmentFile do

  describe ".path" do
    subject { attachment_file.path }
    let(:attachment_file) { FactoryGirl.create(:attachment_file, :id => attachment_file_id, :data_file_name => "test.jpg") }
    
    describe "attachment_file_path" do
      context "id is 1 digit" do
        let(:attachment_file_id) { 1 }
        it { expect(subject).to eq("/system/attachment_files/0000/0001/test.jpg") }
      end
      
      context "id is 4 digits" do
        let(:attachment_file_id) { 1234 }
        it { expect(subject).to eq("/system/attachment_files/0000/1234/test.jpg") }
      end
      
      context "id is 5 digits" do
        let(:attachment_file_id) { 12345 }
        it { expect(subject).to eq("/system/attachment_files/0001/2345/test.jpg") }
      end
      
      context "id is 8 digits" do
        let(:attachment_file_id) { 12345678 }
        it { expect(subject).to eq("/system/attachment_files/1234/5678/test.jpg") }
      end
    end
  end

  describe ".data_fingerprint" do
    let(:attachment_file) { FactoryGirl.create(:attachment_file) }
    before{attachment_file.data_fingerprint = "test"}
    it {expect(attachment_file.data_fingerprint).to eq("test")}
  end
  
  describe ".save_geometry" do
    let(:user) { FactoryGirl.create(:user) }
    let(:attachment_file) { AttachmentFile.new(data: fixture_file_upload("/files/test_image.jpg",'image/jpeg')) }
    before do
      User.current = user
      attachment_file
    end
    it {expect(attachment_file.original_geometry).to eq("2352x1568")}
  end
end
