require "spec_helper"

describe "AttachmentFile" do
  describe "Path" do
    let(:attachment_file){ FactoryGirl.create(:attachment_file)}
    it{expect(attachment_file.path).to eq("/system/attachment_files/" + attachment_file.id.to_s + "/" + attachment_file.data_file_name)}
  end
end
