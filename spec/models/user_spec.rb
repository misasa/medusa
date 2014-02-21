require "spec_helper"

describe User do
  describe "self.current" do
    let(:user){ FactoryGirl.create(:user) }
    before { User.current = user }
    it{ expect(User.current.id).to eq user.id }
  end

  describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:user, username: username,email: "test1@test.co.jp") }
      context "is presence" do
        let(:username) { "sample_user" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:username) { "" }
        it { expect(obj).not_to be_valid }
      end
      context "is 255 characters" do
        let(:username) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:username) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
      context "is duplicate" do
        let(:user){ FactoryGirl.create(:user) }
        let(:username) { user.username }
        it { expect(obj).not_to be_valid }
      end
    end
  end

end
