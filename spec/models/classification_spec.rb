require 'spec_helper'

describe Classification do

  describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:classification, name: name) }
      context "is presence" do
        let(:name) { "sample_classification" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:name) { "" }
        it { expect(obj).not_to be_valid }
      end
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

  describe "full_name" do
    let(:parent){ FactoryGirl.build(:classification_parent)}
    let(:child){ FactoryGirl.build(:classification_child)}
    let(:grandchild){ FactoryGirl.build(:classification_grandchild)}
    context "new parent full_name" do
      before{parent.save}
      it{expect(parent).to be_persisted}
      it{expect(parent.full_name).to eq parent.name}
    end
    context "new child full_name" do
      before do
        parent.save
        child.parent_id = parent.id
        child.save
      end
      it{expect(child).to be_persisted}
      it{expect(child.full_name).to eq(parent.full_name + ":" + child.name)}
    end
    context "new grandchild full_name" do
      before do
        parent.save
        child.parent_id = parent.id
        child.save
        grandchild.parent_id = child.id
        grandchild.save
      end
      it{expect(grandchild).to be_persisted}
      it{expect(grandchild.full_name).to eq(child.full_name + ":" + grandchild.name)}
    end
    context "change parent name" do
      before do
        parent.save
        child.parent_id = parent.id
        child.save
        grandchild.parent_id = child.id
        grandchild.save
        parent.name = "parent2"
        parent.save
        child.reload
        grandchild.reload
      end
      it{expect(parent.full_name).to eq parent.name}
      it{expect(child.full_name).to eq(parent.full_name + ":" + child.name)}
      it{expect(grandchild.full_name).to eq(child.full_name + ":" + grandchild.name)}
    end
  end
end
