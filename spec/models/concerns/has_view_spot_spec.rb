require "spec_helper"

class HasViewSpotSpec < ApplicationRecord
  include HasViewSpot
end

class HasViewSpotSpecMigration < ActiveRecord::Migration[4.2]
  def self.up
    create_table :has_view_spot_specs do |t|
      t.string :name
    end
  end
  def self.down
    drop_table :has_view_spot_specs
  end
end

describe HasViewSpot do
  let(:klass) { HasViewSpotSpec }
  let(:migration) { HasViewSpotSpecMigration }

  before { migration.suppress_messages { migration.up } }
  after { migration.suppress_messages { migration.down } }

  describe "#has_image?" do
    subject { obj.has_image? }
    let(:obj) { klass.create(name: "foo") }
    context "obj has attachment_files" do
      before { allow(obj).to receive(:attachment_files).and_return(attachment_files) }
      let(:attachment_files) { [attachment_file_1, attachment_file_2] }
      let(:attachment_file_1) { double(:attachment_file_1) }
      let(:attachment_file_2) { double(:attachment_file_2) }
      context "attachment_files not include image" do
        before do
          allow(attachment_file_1).to receive(:image?).and_return(false)
          allow(attachment_file_2).to receive(:image?).and_return(false)
        end
        it { expect(subject).to eq false }
      end
      context "attachment_files include image" do
        before do
          allow(attachment_file_1).to receive(:image?).and_return(false)
          allow(attachment_file_2).to receive(:image?).and_return(true)
        end
        it { expect(subject).to eq true }
      end
    end
    context "obj not have attachment_files" do
      before { allow(obj).to receive(:attachment_files).and_return([]) }
      it { expect(subject).to eq false }
    end
  end

end
