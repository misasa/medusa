require 'spec_helper'

describe Box do

  describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:box, name: name) }
      context "is presence" do
        let(:name) { "sample_box_type" }
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
      describe "uniqueness" do
        let(:parent_box) { FactoryGirl.create(:box) }
        let(:child_box) { FactoryGirl.create(:box, name: "box", parent_id: parent_box.id) }
        let(:obj) { FactoryGirl.build(:box, name: "box", parent_id: parent_id) }
        before { child_box }
        context "uniq name with parent" do
          let(:parent_id) { nil }
          it { expect(obj).to be_valid }
        end
        context "duplicate name" do
          let(:parent_id) { parent_box.id }
          it { expect(obj).not_to be_valid }
        end
      end
    end
    describe "parent_id" do
      let(:parent_box) { FactoryGirl.create(:box) }
      let(:box) { FactoryGirl.create(:box, parent_id: parent_id) }
      let(:user) { FactoryGirl.create(:user) }
      before do
        User.current = user
        box
      end
      context "is nil" do
        let(:parent_id) { nil }
        it { expect(box).to be_valid }
      end
      context "is present" do
        let(:parent_id) { parent_box.id }
        context "not equal self.id" do
          it { expect(box).to be_valid }
        end
        context "equal self.id" do
          before { box.parent_id = box.id }
          it { expect(box).not_to be_valid }
        end
      end
    end
  end

  describe "callbacks" do
    describe "after_save" do
      describe "reset_path" do
        let(:box) { FactoryGirl.build(:box, path: "path", parent_id: parent_id) }
        before { box.save }
        context "box has no parent" do
          let(:parent_id) { nil }
          it { expect(box.path).to eq "" }
        end
        context "box has a parent" do
          let(:parent_id) { parent.id }
          let(:parent) { FactoryGirl.create(:box) }
          it { expect(box.path).to eq "/#{parent.name}" }
        end
        context "box has parent and grand_parent" do
          let(:parent_id) { parent.id }
          let(:parent) { FactoryGirl.create(:box, parent_id: grand_parent.id) }
          let(:grand_parent) { FactoryGirl.create(:box) }
          it { expect(box.path).to eq "/#{grand_parent.name}/#{parent.name}" }
        end
      end
    end
  end
end
