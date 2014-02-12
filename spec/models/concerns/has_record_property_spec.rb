require "spec_helper"

class HasRecordPropertySpec < ActiveRecord::Base
  include HasRecordProperty
end

class HasRecordPropertySpecMigration < ActiveRecord::Migration
  def self.up
    create_table :has_record_property_specs do |t|
      t.string :name
    end
  end
  def self.down
    drop_table :has_record_property_specs
  end
end

describe HasRecordProperty do
  let(:klass) { HasRecordPropertySpec }
  let(:migration) { HasRecordPropertySpecMigration }

  before { migration.suppress_messages { migration.up } }
  after { migration.suppress_messages { migration.down } }

  describe "deligate methods" do
    let(:obj) { klass.create(name: "foo") }
    let(:record_property) { obj.build_record_property(global_id: global_id) }
    let(:global_id) { "12345" }
    let(:writable) { false }
    let(:readable) { true }
    before do
      allow(record_property).to receive(:writable?).and_return(writable)
      allow(record_property).to receive(:readable?).and_return(readable)
    end
    it { expect(obj.global_id).to eq global_id }
    it { expect(obj.readable?).to be_truthy }
  end

  describe ".readables" do
    subject { HasRecordPropertySpec.readables(user) }
    let(:obj) { klass.create(name: "foo") }
    let(:user) { FactoryGirl.create(:user_foo) }
    let(:group) { FactoryGirl.create(:group) }
    let(:another_user) { FactoryGirl.create(:user_baa) }
    let(:another_group) { FactoryGirl.create(:group) }
    before do
      GroupMember.create(user: user, group: group)
      obj.create_record_property(owner_readable: owner_readable, group_readable: group_readable, guest_readable: guest_readable, user_id: user_id, group_id: group_id)
    end
    context "when user is record owner." do
      let(:user_id) { user.id }
      let(:group_id) { another_group.id }
      let(:group_readable) { false }
      let(:guest_readable) { false }
      context "when owner is permitted to read." do
        let(:owner_readable) { true }
        it { expect(subject).to be_present }
      end
      context "when owner is not permitted to read." do
        let(:owner_readable) { false }
        it { expect(subject).to be_blank }
      end
    end
    context "when user is not record owner." do
      let(:user_id) { another_user.id }
      let(:owner_readable) { true }
      context "when user belongs to record group." do
        let(:group_id) { group.id }
        let(:guest_readable) { false }
        context "when group member is permitted to read." do
          let(:group_readable) { true }
          it { expect(subject).to be_present }
        end
        context "when group member is not permitted to read." do
          let(:group_readable) { false }
          it { expect(subject).to be_blank }
        end
      end
      context "when user does not belongs to record group." do
        let(:group_id) { another_group.id }
        let(:group_readable) { true }
        context "when guest is permitted to read." do
          let(:guest_readable) { true }
          it { expect(subject).to be_present }
        end
        context "when guest is not permitted to read." do
          let(:guest_readable) { false }
          it { expect(subject).to be_blank }
        end
      end
    end
  end

  describe "#writable?" do
    subject { obj.writable?(user) }
    let(:obj) { klass.create(name: "foo") }
    let(:user) { FactoryGirl.create(:user_foo) }
    before { obj.create_record_property }
    context "when obj is new_record." do
      before { allow(obj).to receive(:new_record?).and_return(true) }
      context "when record_property is writable." do
        before { allow(obj.record_property).to receive(:writable?).with(user).and_return(true) }
        it { expect(subject).to eq true }
      end
      context "when record_property isn't writable." do
        before { allow(obj.record_property).to receive(:writable?).with(user).and_return(false) }
        it { expect(subject).to eq true }
      end
    end
    context "when obj isn't new_record." do
      before { allow(obj).to receive(:new_record?).and_return(false) }
      context "when record_property is writable." do
        before { allow(obj.record_property).to receive(:writable?).with(user).and_return(true) }
        it { expect(subject).to eq true }
      end
      context "when record_property isn't writable." do
        before { allow(obj.record_property).to receive(:writable?).with(user).and_return(false) }
        it { expect(subject).to eq false }
      end
    end
  end
  
  describe "after_create create_record_property" do
    let(:stone) { FactoryGirl.create(:stone)}
    let(:user) { FactoryGirl.create(:user) }
    it "" do
      User.current = user
      stone.save
      expect(stone.record_property).not_to be_nil
      expect(stone.record_property.persisted?).to be true
    end
  end
end
