require "spec_helper"

class HasAttachmentFileSpec < ActiveRecord::Base
  include HasAttachmentFile
end

class HasAttachmentFileSpecMigration < ActiveRecord::Migration
  def self.up
    create_table :has_attachment_file_specs do |t|
      t.string :name
    end
  end
  def self.down
    drop_table :has_attachment_file_specs
  end
end

describe HasAttachmentFile do
  let(:klass) { HasAttachmentFileSpec }
  let(:migration) { HasAttachmentFileSpecMigration }

  before { migration.suppress_messages { migration.up } }
  after { migration.suppress_messages { migration.down } }
  
  describe "attachment_pdf_files" do
    subject { obj.attachment_pdf_files }
    let(:obj) { klass.create(name: "foo") }
    let(:attachment_file_1) { FactoryGirl.create(:attachment_file, data_file_name: "file_name_1", data_content_type: data_content_type_1) }
    let(:attachment_file_2) { FactoryGirl.create(:attachment_file, data_file_name: "file_name_2", data_content_type: data_content_type_2) }
    let(:attachment_file_3) { FactoryGirl.create(:attachment_file, data_file_name: "file_name_3", data_content_type: data_content_type_3) }
    before do
      obj.attachment_files << attachment_file_1
      obj.attachment_files << attachment_file_2
      obj.attachment_files << attachment_file_3
    end
    context "data_content_type is pdf" do
      let(:data_content_type_1) { data_content_type_2 }
      let(:data_content_type_2) { "application/pdf" }
      let(:data_content_type_3) { "image/jpeg" }
      it { expect(subject).to be_present }
      it { expect(subject).to include(attachment_file_1) }
      it { expect(subject).to include(attachment_file_2) }
    end
    context "data_content_type is jpeg" do
      let(:data_content_type_1) { data_content_type_2 }
      let(:data_content_type_2) { data_content_type_3 }
      let(:data_content_type_3) { "image/jpeg" }
      it { expect(subject).to be_blank }
    end
  end
  
  describe "attachment_image_files" do
    subject { obj.attachment_image_files }
    let(:obj) { klass.create(name: "foo") }
    let(:attachment_file_1) { FactoryGirl.create(:attachment_file, data_file_name: "file_name_1", data_content_type: data_content_type_1) }
    let(:attachment_file_2) { FactoryGirl.create(:attachment_file, data_file_name: "file_name_2", data_content_type: data_content_type_2) }
    let(:attachment_file_3) { FactoryGirl.create(:attachment_file, data_file_name: "file_name_3", data_content_type: data_content_type_3) }
    before do
      obj.attachment_files << attachment_file_1
      obj.attachment_files << attachment_file_2
      obj.attachment_files << attachment_file_3 
    end
    context "data_content_type is jpeg" do
      let(:data_content_type_1) { data_content_type_2 }
      let(:data_content_type_2) { "image/jpeg" }
      let(:data_content_type_3) { "application/pdf" }
      it { expect(subject).to be_present }
      it { expect(subject).to include(attachment_file_2) }
      it { expect(subject).to include(attachment_file_1) }

    end
    context "data_content_type is pdf" do
      let(:data_content_type_1) { data_content_type_2 }
      let(:data_content_type_2) { data_content_type_3 }
      let(:data_content_type_3) { "application/pdf" }
      it { expect(subject).to be_blank }
    end
  end
  
end
