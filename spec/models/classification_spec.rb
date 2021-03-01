require 'spec_helper'

describe Classification do

  describe "validates" do
    describe "name" do
      let(:obj) { FactoryBot.build(:classification, name: name, sesar_material: "Rock") }
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
    describe "sesar_material" do
      let(:obj) { FactoryBot.build(:classification, sesar_material: sesar_material) }
      context "is presence" do
        let(:sesar_material) { "sample" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:sesar_material) { "" }
        it { expect(obj).not_to be_valid }
      end
      context "is 255 characters" do
        let(:sesar_material) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:sesar_material) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
    end
  end

  describe "full_name" do
    let(:parent){ FactoryBot.build(:classification_parent, sesar_material: "Rock")}
    let(:child){ FactoryBot.build(:classification_child, sesar_material: "Rock")}
    let(:grandchild){ FactoryBot.build(:classification_grandchild, sesar_material: "Rock")}
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
        parent.reload
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
  
  describe "check_classification(material, classification)" do
    subject { classification.check_classification(sesar_material, sesar_classification) }
    let(:classification) { FactoryBot.create(:classification) }
    context "sesar_materialがBiology" do
      let(:sesar_material) { "Biology" }
      context "対象のsesar_classificationが存在する" do
        let(:sesar_classification) { "Macrobiology>MacrobiologyType>Coral" }
        it { expect(subject).to be true }
      end
      context "対象のsesar_classificationが存在しない" do
        let(:sesar_classification) { "MineralType>Acanthite" }
        it { expect(subject).to be false }
      end
    end
    context "sesar_materialがMineral" do
      let(:sesar_material) { "Mineral" }
      context "対象のsesar_classificationが存在する" do
        let(:sesar_classification) { "MineralType>Bakhchisaraitsevite" }
        it { expect(subject).to be true }
      end
      context "対象のsesar_classificationが存在しない" do
        let(:sesar_classification) { "Unknown" }
        it { expect(subject).to be false }
      end
    end
    context "sesar_materialがRock" do
      let(:sesar_material) { "Rock" }
      context"対象のsesar_classificationが存在する" do
        let(:sesar_classification) { "Igneous" }
        it { expect(subject).to be true }
      end
      context "対象のsesar_classificationが存在しない" do
        let(:sesar_classification) { "Igne" }
        it { expect(subject).to be false }
      end
    end
    context "materialがBiology,Mineral,Rock以外" do
      let(:sesar_material) { "Gas" }
      context"sesar_classificationが入力されている" do
        let(:sesar_classification) { "aaaa" }
        it { expect(subject).to be false }
      end
      context "sesar_classificationが入力されていない" do
        let(:sesar_classification) { "" }
        it { expect(subject).to be true }
      end
    end
    context "sesar_classificationがblank" do
      let(:sesar_material) {"Rock"}
      let(:sesar_classification) {""}
      it { expect(subject).to be true }
    end
  end
end
