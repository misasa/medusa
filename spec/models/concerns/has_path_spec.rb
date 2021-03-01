require "spec_helper"

class HasPathSpec < ApplicationRecord
  include HasPath
end

class HasPathSpecMigration < ActiveRecord::Migration[4.2]
  def self.up
    create_table :has_path_specs do |t|
      t.string :name
      t.timestamps
    end
  end
  def self.down
    drop_table :has_path_specs
  end
end

describe HasPath do

  before { migration.suppress_messages { migration.up } }
  after { migration.suppress_messages { migration.down } }
  
  describe "store_new_path" do
    let(:klass) { HasPathSpec }
    let(:migration) { HasPathSpecMigration }
    let(:obj) { klass.create(name: "foo") }
    context "path_changed?,path_idsが定義されている" do
      before do
        allow_any_instance_of(klass).to receive(:path_changed?).and_return(true)
        allow_any_instance_of(klass).to receive(:path_ids).and_return([1])
      end
      it "path新規作成" do
        obj
        path = Path.first
        expect(path).to be_truthy
        expect(path.ids).to eq [1]
        expect(path.brought_in_at).to_not eq nil
        expect(path.brought_out_at).to eq nil
      end
      it "path更新" do
        obj.store_new_path
        path = Path.all
        expect(path.size).to eq 2
        expect(path[0]).to be_truthy
        expect(path[0].brought_out_at).to_not eq nil
        expect(path[1]).to be_truthy
        expect(path[1].brought_out_at).to eq nil
      end
    end
    context "path_changed?未定義" do
      before { allow_any_instance_of(klass).to receive(:path_ids).and_return([1]) }
      it "raiseNotImplementedError" do
        expect{ obj }.to raise_error(NotImplementedError, "You must implement HasPathSpec#path_ids method.")
      end
    end
    context "path_ids未定義" do
      before { allow_any_instance_of(klass).to receive(:path_changed?).and_return(true) }
      it "raiseNotImplementedError" do
        expect{ obj }.to raise_error(NotImplementedError, "You must implement HasPathSpec#path_ids method.")
      end
    end
  end
end

