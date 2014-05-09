require "spec_helper"

class HasAttachmentFileSpec < ActiveRecord::Base
  include HasAttachmentFile
  
  has_many :attachment_files, through: :attachings
  has_many :attachings, as: :attachable, dependent: :destroy
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
    let(:attachment_file) { FactoryGirl.create(:attachment_file, data_file_name: "file_name", data_content_type: data_type) }
    before { obj.attachment_files << attachment_file }
    context "data_content_type is pdf" do
      let(:data_type) { "application/pdf" }
      it { expect(subject).to be_present }
      it { expect(subject).to eq [attachment_file] }
    end
    context "data_content_type is jpeg" do
      let(:data_type) { "image/jpeg" }
      it { expect(subject).to be_blank }
    end
  end
  
end
