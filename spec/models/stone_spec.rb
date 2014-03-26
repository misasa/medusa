require "spec_helper"

describe Stone do
  describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:stone, name: name) }
      context "is presence" do
        let(:name) { "sample_obj_name" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:name) { "" }
        it { expect(obj).not_to be_valid }
      end
      describe "length" do
        context "is 255 characters" do
          let(:name) { "a" * 255 }
          it { expect(obj).to be_valid }
        end
        context "is 256 characters" do
          let(:name) { "a" * 256 }
          it { expect(obj).not_to be_valid }
        end
      end
    end
    describe "parent_id" do
      let(:parent_stone) { FactoryGirl.create(:stone) }
      let(:stone) { FactoryGirl.create(:stone, parent_id: parent_id) }
      let(:user) { FactoryGirl.create(:user) }
      before do
        User.current = user
        stone
      end
      context "is nil" do
        let(:parent_id) { nil }
        it { expect(stone).to be_valid }
      end
      context "is present" do
        let(:parent_id) { parent_stone.id }
        context "not equal self.id" do
          it { expect(stone).to be_valid }
        end
        context "equal self.id" do
          before { stone.parent_id = stone.id }
          it { expect(stone).not_to be_valid }
        end
      end
    end
  end

end
