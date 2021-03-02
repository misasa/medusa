require "spec_helper"

class OutputCsvSpec < ApplicationRecord
  include OutputCsv
end

class OutputCsvSpecMigration < ActiveRecord::Migration[4.2]
  def self.up
    create_table :output_csv_specs do |t|
      t.string :name
      t.string :global_id
    end
  end
  def self.down
    drop_table :output_csv_specs
  end
end

describe OutputCsv do
  let(:klass) { OutputCsvSpec }
  let(:migration) { OutputCsvSpecMigration }

  before { migration.suppress_messages { migration.up } }
  after { migration.suppress_messages { migration.down } }

  describe "constants" do
    describe "LABEL_HEADER" do
      subject { klass::LABEL_HEADER }
      it { expect(subject).to eq ["Id","Name"] }
    end
  end

  describe "build_label" do
    subject { obj.build_label }
    let(:obj) { klass.create(name: "foo", global_id: "1234") }
    it { expect(subject).to eq "Id,Name\n1234,foo\n" }
  end

  describe "build_bundle_label" do
    subject { klass::build_bundle_label(resources) }
    let(:resources) { [obj_1, obj_2] }
    let(:obj_1) { klass.create(name: "foo", global_id: "123") }
    let(:obj_2) { klass.create(name: "bar", global_id: "456") }
    it { expect(subject).to eq "Id,Name\n123,foo\n456,bar\n" }
  end

end
