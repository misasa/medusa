require "spec_helper"

describe RecordProperty do
  shared_examples "checking user permission" do |method, owner_permission_attribute, group_permission_attribute, guest_permission_attribute|
    subject { record_property.send(method, user) }
    let(:record_property) { FactoryGirl.build(:record_property, user_id: user_id, group_id: group_id, owner_permission_attribute => owner_permission, group_permission_attribute => group_permission, guest_permission_attribute => guest_permission) }
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }
    before { GroupMember.create(user: user, group: group) }
    context "when user is owner." do
      let(:user_id) { user.id }
      let(:group_id) { nil }
      let(:group_permission) { false }
      let(:guest_permission) { false }
      context "when owner is permitted." do
        let(:owner_permission) { true }
        it { expect(subject).to be_truthy }
      end
      context "when owner is not permitted." do
        let(:owner_permission) { false }
        it { expect(subject).to be_falsey }
      end
    end
    context "when user is not owner." do
      let(:user_id) { nil }
      let(:owner_permission) { true }
      context "when user belongs to group." do
        let(:group_id) { group.id }
        let(:guest_permission) { false }
        context "when group is permitted." do
          let(:group_permission) { true }
          it { expect(subject).to be_truthy }
        end
        context "when group is not permitted." do
          let(:group_permission) { false }
          it { expect(subject).to be_falsey }
        end
      end
      context "when user does not belongs to group." do
        let(:group_id) { nil }
        let(:group_permission) { true }
        context "when guest is permitted." do
          let(:guest_permission) { true }
          it { expect(subject).to be_truthy }
        end
        context "when guest is not permitted." do
          let(:guest_permission) { false }
          it { expect(subject).to be_falsey }
        end
      end
    end
  end

  describe ".writable?" do
    it_behaves_like "checking user permission", :writable?, :owner_writable?, :group_writable?, :guest_writable?
  end

  describe ".readable?" do
    it_behaves_like "checking user permission", :readable?, :owner_readable?, :group_readable?, :guest_readable?
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

  describe ".generate_global_id" do
    let(:record_property){FactoryGirl.build(:record_property,global_id: nil)}
    before { record_property.generate_global_id }
    it{expect(record_property.global_id).not_to be_nil}
  end

  describe "validates" do
    describe "published_at" do
      let(:record_property){ FactoryGirl.build(:record_property, published: published, published_at: published_at) }
      let(:published) { false }
      let(:published_at) { nil }
      context "published is false" do
        context "published_at is nil" do
          it { expect(record_property).to be_valid }
        end
        context "published_at is present" do
          let(:published_at) { Time.now }
          it { expect(record_property).to be_valid }
        end
      end
      context "published is true" do
        let(:published) { true }
        context "published_at is nil" do
          it { expect(record_property).not_to be_valid }
        end
        context "published_at is present" do
          let(:published_at) { Time.now }
          it { expect(record_property).to be_valid }
        end
      end
    end
  end

  describe "callbacks" do
    describe "generate_global_id" do
      let(:user) { FactoryGirl.create(:user) }
      context "global_id is nil" do
        let(:record_property){ FactoryGirl.build(:record_property, user_id: user.id, global_id: nil) }
        before { record_property.save }
        it{ expect(record_property.global_id).to be_present }
      end
      context "global_id is not nil" do
        let(:record_property){ FactoryGirl.build(:record_property, user_id: user.id, global_id: "xxx") }
        before { record_property.save }
        it{ expect(record_property.global_id).to eq "xxx" }
      end
    end
  end

end
