require "spec_helper"

describe RecordProperty do
  shared_examples "checking user permission" do |method, permission|
    subject { record_property.send(method, user) }
    let(:record_property) { FactoryGirl.build(:record_property, user_id: user_id, group_id: group_id, permission_u: permission_u, permission_g: permission_g, permission_o: permission_o) }
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }
    before { GroupMember.create(user: user, group: group) }
    context "when user is owner." do
      let(:user_id) { user.id }
      let(:group_id) { nil }
      let(:permission_g) { 0 }
      let(:permission_o) { 0 }
      context "when owner is permitted." do
        let(:permission_u) { permission }
        it { expect(subject).to be_truthy }
      end
      context "when owner is not permitted." do
        let(:permission_u) { 0 }
        it { expect(subject).to be_falsey }
      end
    end
    context "when user is not owner." do
      let(:user_id) { nil }
      let(:permission_u) { RecordProperty::WRITE | RecordProperty::READ }
      context "when user belongs to group." do
        let(:group_id) { group.id }
        let(:permission_o) { 0 }
        context "when group is permitted." do
          let(:permission_g) { permission }
          it { expect(subject).to be_truthy }
        end
        context "when group is not permitted." do
          let(:permission_g) { 0 }
          it { expect(subject).to be_falsey }
        end
      end
      context "when user does not belongs to group." do
        let(:group_id) { nil }
        let(:permission_g) { RecordProperty::WRITE | RecordProperty::READ }
        context "when guest is permitted." do
          let(:permission_o) { permission }
          it { expect(subject).to be_truthy }
        end
        context "when guest is not permitted." do
          let(:permission_o) { 0 }
          it { expect(subject).to be_falsey }
        end
      end
    end
  end

  shared_examples "permission check to write" do |method, attribute|
    subject { record_property.send(method) }
    let(:record_property) { FactoryGirl.build(:record_property, attribute => permission) }
    context "when owner is permitted to write and read." do
      let(:permission) { RecordProperty::WRITE | RecordProperty::READ }
      it { expect(subject).to be_truthy }
    end
    context "when owner is permitted to write." do
      let(:permission) { RecordProperty::WRITE }
      it { expect(subject).to be_truthy }
    end
    context "when owner is permitted to read." do
      let(:permission) { RecordProperty::READ }
      it { expect(subject).to be_falsey }
    end
    context "when owner is not permitted to all." do
      let(:permission) { 0 }
      it { expect(subject).to be_falsey }
    end
  end

  shared_examples "permission check to read" do |method, attribute|
    subject { record_property.send(method) }
    let(:record_property) { FactoryGirl.build(:record_property, attribute => permission) }
    context "when owner is permitted to write and read." do
      let(:permission) { RecordProperty::WRITE | RecordProperty::READ }
      it { expect(subject).to be_truthy }
    end
    context "when owner is permitted to write." do
      let(:permission) { RecordProperty::WRITE }
      it { expect(subject).to be_falsey }
    end
    context "when owner is permitted to read." do
      let(:permission) { RecordProperty::READ }
      it { expect(subject).to be_truthy }
    end
    context "when owner is not permitted to all." do
      let(:permission) { 0 }
      it { expect(subject).to be_falsey }
    end
  end

  describe ".writable?" do
    it_behaves_like "checking user permission", :writable?, RecordProperty::WRITE
  end

  describe ".readable?" do
    it_behaves_like "checking user permission", :readable?, RecordProperty::READ
  end

  describe ".owner?" do
    subject { record_property.owner?(user) }
    let(:record_property) { FactoryGirl.build(:record_property, user_id: user_id) }
    let(:user) { FactoryGirl.create(:user) }
    context "when match user_id" do
      let(:user_id) { user.id }
      it { expect(subject).to be_truthy }
    end
    context "when unmatch user_id" do
      let(:user_id) { nil }
      it { expect(subject).to be_falsey }
    end
  end

  describe ".group?" do
    subject { record_property.group?(user) }
    let(:record_property) { FactoryGirl.build(:record_property, user: nil, group_id: group_id) }
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }
    before { GroupMember.create(user: user, group: group) }
    context "when match group_id" do
      let(:group_id) { group.id }
      it { expect(subject).to be_truthy }
    end
    context "when unmatch group_id" do
      let(:group_id) { nil }
      it { expect(subject).to be_falsey }
    end
  end

  describe ".owner_writable?" do
    it_behaves_like "permission check to write", :owner_writable?, :permission_u
  end

  describe ".owner_readable?" do
    it_behaves_like "permission check to read", :owner_readable?, :permission_u
  end

  describe ".group_writable?" do
    it_behaves_like "permission check to write", :group_writable?, :permission_g
  end

  describe ".group_readable?" do
    it_behaves_like "permission check to read", :group_readable?, :permission_g
  end

  describe ".guest_writable?" do
    it_behaves_like "permission check to write", :guest_writable?, :permission_o
  end

  describe ".guest_readable?" do
    it_behaves_like "permission check to read", :guest_readable?, :permission_o
  end
end
