require "spec_helper"

describe Stone do
  describe ".to_pml", :current => true do
    let(:stone1) { FactoryGirl.create(:stone) }
    let(:stone2) { FactoryGirl.create(:stone) }
    let(:stones) { [stone1] }
    let(:analysis_1) { FactoryGirl.create(:analysis, stone_id: stone1.id)}
    let(:analysis_2) { FactoryGirl.create(:analysis, stone_id: stone1.id)}
    let(:analysis_3) { FactoryGirl.create(:analysis, stone_id: stone2.id)}
    let(:analysis_4) { FactoryGirl.create(:analysis, stone_id: stone2.id)}
    before do
      stone1
      stone2
      analysis_1
      analysis_2
      analysis_3
      analysis_4
    end
    it { expect(stone1.analyses.count).to eq 2}
    it { expect(stone1.to_pml).to eql([analysis_2, analysis_1].to_pml)}
    it { expect(stone2.analyses.count).to eq 2}
    it { expect(stone2.to_pml).to eql([analysis_4, analysis_3].to_pml)}
    it { expect(stones.to_pml).to eql([analysis_2, analysis_1].to_pml) }
  end

  describe ".descendants" do
    let(:root) { FactoryGirl.create(:stone, name: "root") }
    let(:child_1){ FactoryGirl.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    before do
      root;child_1;child_1_1;
    end
    it {
      expect(root.descendants).to match_array([child_1, child_1_1])
    }
  end

  describe ".self_and_descendants" do
    let(:root) { FactoryGirl.create(:stone, name: "root") }
    let(:child_1){ FactoryGirl.create(:stone, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:stone, parent_id: child_1.id) }
    before do
      root;child_1;child_1_1;
    end
    it {
      expect(root.self_and_descendants).to match_array([root, child_1, child_1_1])
    }
  end

  describe ".blood_path" do
      let(:parent_stone) { FactoryGirl.create(:stone) }
      let(:stone) { FactoryGirl.create(:stone, parent_id: parent_id) }
      before do
        parent_stone
        stone
      end
      describe "parent" do
        context "us not present" do
          let(:parent_id) { nil }
           #before { stone.parent_id = parent_stone.id }
           it { expect(stone.blood_path).to eq "/#{stone.name}" }          
        end
        context "is present" do
          let(:parent_id) { parent_stone.id }
           before { stone.parent_id = parent_stone.id }
           it { expect(stone.blood_path).to eq "/#{parent_stone.name}/#{stone.name}" }          
        end
      end
  end

  describe "#delete_table_analysis" do
    subject { stone.send(:delete_table_analysis, analysis_1) }
    let(:stone) { FactoryGirl.create(:stone) }
    let(:analysis_1) { FactoryGirl.create(:analysis, stone_id: stone.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, stone_id: stone.id) }
    let(:table_analysis_1) { FactoryGirl.create(:table_analysis, table: table, stone: stone, analysis: analysis_1, priority: 1) }
    let(:table_analysis_2) { FactoryGirl.create(:table_analysis, table: table, stone: stone, analysis: analysis_2, priority: 2) }
    let(:table) { FactoryGirl.create(:table) }
    before do
      table_analysis_1
      table_analysis_2
    end
    it { expect{ subject }.to change(TableAnalysis, :count).from(2).to(1) }
    it { subject; expect(TableAnalysis.exists?(analysis_id: analysis_2.id)).to eq true }
  end

  describe "#set_stone_custom_attributes" do
    subject { stone.set_stone_custom_attributes }
    let(:stone) { FactoryGirl.create(:stone) }
    let(:custom_attribute_1) { FactoryGirl.create(:custom_attribute, name: "bbb") }
    let(:custom_attribute_2) { FactoryGirl.create(:custom_attribute, name: "aaa") }
    context "CustomAttribute not exists" do
      it { expect(subject.size).to eq 0 }
    end
    context "CustomAttribute exists" do
      before do
        custom_attribute_1
        custom_attribute_2
      end
      context "stone is not associate custom_attribute" do
        it { expect(subject.size).to eq(CustomAttribute.count) }
        it { expect(subject[0].custom_attribute_id).to eq(custom_attribute_2.id) }
        it { expect(subject[0].persisted?).to eq false }
        it { expect(subject[1].custom_attribute_id).to eq(custom_attribute_1.id) }
        it { expect(subject[1].persisted?).to eq false }
      end
      context "stone associate custom_attribute" do
        before { FactoryGirl.create(:stone_custom_attribute, stone_id: stone.id, custom_attribute_id: custom_attribute_1.id) }
        it { expect(subject.size).to eq (CustomAttribute.count) }
        it { expect(subject[0].custom_attribute_id).to eq(custom_attribute_2.id) }
        it { expect(subject[0].persisted?).to eq false }
        it { expect(subject[1].custom_attribute_id).to eq(custom_attribute_1.id) }
        it { expect(subject[1].persisted?).to eq true }
      end
    end
  end

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
      let(:child_stone) { FactoryGirl.create(:stone, parent_id: stone.id) }
      let(:user) { FactoryGirl.create(:user) }
      before do
        User.current = user
        parent_stone
        stone
        child_stone
      end
      context "is nil" do
        let(:parent_id) { nil }
        it { expect(stone).to be_valid }
      end
      context "is present" do
        let(:parent_id) { parent_stone.id }
        context "and parent_id equal self.id" do
          before { stone.parent_id = stone.id }
          it { expect(stone).not_to be_valid }
        end
        context "and parent_id equal child_box.id" do
          before { stone.parent_id = child_stone.id }
          it { expect(stone).not_to be_valid }
        end
        context "and valid id" do
          it { expect(stone).to be_valid }
        end
      end
    end
    describe "igsn" do
      let(:obj) { FactoryGirl.build(:stone, name: "samplename", igsn: igsn) }
      context "9桁の場合" do
        let(:igsn) { "abcd12345" }
        it { expect(obj).to be_valid }
      end
      context "10桁の場合" do
        let(:igsn) { "abcd123456" }
        it { expect(obj).not_to be_valid }
      end
      context "uniqueではない場合" do
        before { FactoryGirl.create(:stone, name: "aiueo", igsn: "123456789") }
        let(:obj) { FactoryGirl.build(:stone, name: "samplename2", igsn: "123456789") }
        it { expect(obj).not_to be_valid }
      end
    end
    describe "age_min" do
      let(:obj) { FactoryGirl.build(:stone, name: "samplename", age_min: age_min) }
      context "数値の場合" do
        let(:age_min) { 1 }
        it { expect(obj).to be_valid }
      end
      context "文字列の場合" do
        let(:age_min) { "あ" }
        it { expect(obj).not_to be_valid }
      end
    end
    describe "age_max" do
      let(:obj) { FactoryGirl.build(:stone, name: "samplename", age_max: age_max) }
      context "数値の場合" do
        let(:age_max) { 11 }
        it { expect(obj).to be_valid }
      end
      context "文字列の場合" do
        let(:age_max) { "あ" }
        it { expect(obj).not_to be_valid }
      end
    end
    describe "age_unit" do
      let(:obj) { FactoryGirl.build(:stone, age_unit: age_unit) }
      context "is presence" do
        let(:age_unit) { "a" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:age_unit) { "" }
        it { expect(obj).not_to be_valid }
      end
      describe "length" do
        context "is 255 characters" do
          let(:age_unit) { "a" * 255 }
          it { expect(obj).to be_valid }
        end
        context "is 256 characters" do
          let(:age_unit) { "a" * 256 }
          it { expect(obj).not_to be_valid }
        end
      end
    end
    describe "size" do
      let(:obj) { FactoryGirl.build(:stone, size: size) }
      context "is presence" do
        let(:size) { "111" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:size) { "" }
        it { expect(obj).not_to be_valid }
      end
      describe "length" do
        context "is 255 characters" do
          let(:size) { "1" * 255 }
          it { expect(obj).to be_valid }
        end
        context "is 256 characters" do
          let(:size) { "1" * 256 }
          it { expect(obj).not_to be_valid }
        end
      end
    end
    describe "size_unit" do
      let(:obj) { FactoryGirl.build(:stone, size_unit: size_unit) }
      context "is presence" do
        let(:size_unit) { "a" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:size_unit) { "" }
        it { expect(obj).not_to be_valid }
      end
      describe "length" do
        context "is 255 characters" do
          let(:size_unit) { "a" * 255 }
          it { expect(obj).to be_valid }
        end
        context "is 256 characters" do
          let(:size_unit) { "a" * 256 }
          it { expect(obj).not_to be_valid }
        end
      end
    end
  end

end
