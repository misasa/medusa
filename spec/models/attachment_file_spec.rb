require "spec_helper"

describe AttachmentFile do
  describe "alias_attribute" do
    describe "name" do
      subject { attachment_file.name }
      let(:attachment_file) { FactoryGirl.build(:attachment_file, name: "name", data_file_name: data_file_name) }
      let(:data_file_name) { "test.jpg" }
      it { expect(subject).to eq data_file_name }
    end
  end

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
  
end
