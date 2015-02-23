require "spec_helper"

describe User do
  describe "self.current" do
    let(:user){ FactoryGirl.create(:user) }
    before { User.current = user }
    it{ expect(User.current.id).to eq user.id }
  end

  describe "box_global_id", :current => true do
    let(:user){ FactoryGirl.create(:user) }
    let(:box){ FactoryGirl.create(:box)}
    context "with box" do
      before { 
        user.box = box
        user.save
      }
      it { expect(user.box_global_id).to eq(box.global_id)}
    end
    context "without box" do
      it { expect(user.box_global_id).to be_nil}
    end

  end

  describe "as_json", :current => true do
    let(:user){ FactoryGirl.create(:user) }
    let(:box){ FactoryGirl.create(:box)}
    before { 
      user.box = box
      user.save
    }
    it { expect(user.as_json).to include("box_id" => box.id)}
    it { expect(user.as_json).to include("box_global_id" => box.global_id)}
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
