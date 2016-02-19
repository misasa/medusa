require "spec_helper"

describe Specimen do
  describe ".to_pml", :current => true do
    let(:specimen1) { FactoryGirl.create(:specimen) }
    let(:specimen2) { FactoryGirl.create(:specimen) }
    let(:specimens) { [specimen1] }
    let(:analysis_1) { FactoryGirl.create(:analysis, specimen_id: specimen1.id)}
    let(:analysis_2) { FactoryGirl.create(:analysis, specimen_id: specimen1.id)}
    let(:analysis_3) { FactoryGirl.create(:analysis, specimen_id: specimen2.id)}
    let(:analysis_4) { FactoryGirl.create(:analysis, specimen_id: specimen2.id)}
    before do
      specimen1
      specimen2
      analysis_1
      analysis_2
      analysis_3
      analysis_4
    end
    it { expect(specimen1.analyses.count).to eq 2}
#    it { expect(specimen1.to_pml).to eql([analysis_2, analysis_1].to_pml)}
    it { expect(specimen2.analyses.count).to eq 2}
#    it { expect(specimen2.to_pml).to eql([analysis_4, analysis_3].to_pml)}
#    it { expect(specimens.to_pml).to eql([analysis_2, analysis_1].to_pml) }
  end

  describe ".descendants" do
    let(:root) { FactoryGirl.create(:specimen, name: "root") }
    let(:child_1){ FactoryGirl.create(:specimen, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:specimen, parent_id: child_1.id) }
    before do
      root;child_1;child_1_1;
    end
    it {
      expect(root.descendants).to match_array([child_1, child_1_1])
    }
  end

  describe ".self_and_descendants" do
    let(:root) { FactoryGirl.create(:specimen, name: "root") }
    let(:child_1){ FactoryGirl.create(:specimen, parent_id: root.id) }
    let(:child_1_1){ FactoryGirl.create(:specimen, parent_id: child_1.id) }
    before do
      root;child_1;child_1_1;
    end
    it {
      expect(root.self_and_descendants).to match_array([root, child_1, child_1_1])
    }
  end

  describe ".blood_path" do
      let(:parent_specimen) { FactoryGirl.create(:specimen) }
      let(:specimen) { FactoryGirl.create(:specimen, parent_id: parent_id) }
      before do
        parent_specimen
        specimen
      end
      describe "parent" do
        context "us not present" do
          let(:parent_id) { nil }
           #before { specimen.parent_id = parent_specimen.id }
           it { expect(specimen.blood_path).to eq "/#{specimen.name}" }          
        end
        context "is present" do
          let(:parent_id) { parent_specimen.id }
           before { specimen.parent_id = parent_specimen.id }
           it { expect(specimen.blood_path).to eq "/#{parent_specimen.name}/#{specimen.name}" }          
        end
      end
  end

  describe "#age_mean" do
    subject {specimen.age_mean }
    let(:specimen){ FactoryGirl.create(:specimen, age_min: age_min, age_max: age_max, age_unit: age_unit)}
    let(:age_unit){ "ka" }
    let(:age_min){ 45 }
    let(:age_max){ 55 }
    context "with min and max" do
      let(:age_mean){ 50 }
      let(:age_error){ 5 } 
      let(:age_min){ age_mean - age_error }
      let(:age_max){ age_mean + age_error }
      it { expect(subject).to be_eql(50.0) }
    end

    context "without min" do
      let(:age_min){ nil }
      it { expect(subject).to be_nil}
    end

    context "without max" do
      let(:age_max){ nil }
      it { expect(subject).to be_nil}
    end

    context "without min and max" do
      let(:age_min){ nil }
      let(:age_max){ nil }
      it { expect(subject).to be_nil}
    end
  end

  describe "#age_error" do
    subject {specimen.age_error }
    let(:specimen){ FactoryGirl.create(:specimen, age_min: age_min, age_max: age_max, age_unit: age_unit)}
    let(:age_unit){ "ka" }
    let(:age_min){ 45 }
    let(:age_max){ 55 }
    context "with min and max" do
      let(:age_mean){ 50 }
      let(:age_error){ 5 } 
      let(:age_min){ age_mean - age_error }
      let(:age_max){ age_mean + age_error }
      it { expect(subject).to be_eql(5.0) }
    end

    context "without min" do
      let(:age_min){ nil }
      it { expect(subject).to be_nil}
    end

    context "without max" do
      let(:age_max){ nil }
      it { expect(subject).to be_nil}
    end

    context "without min and max" do
      let(:age_min){ nil }
      let(:age_max){ nil }
      it { expect(subject).to be_nil}
    end
  end

  describe "#age_in_text" do
    subject {specimen.age_in_text }
    let(:specimen){ FactoryGirl.create(:specimen, age_min: age_min, age_max: age_max, age_unit: age_unit)}
    let(:age_unit){ "ka" }
    let(:age_min){ 45 }
    let(:age_max){ 55 }
    context "with min and max" do
      let(:age_mean){ 50 }
      let(:age_error){ 5 } 
      let(:age_min){ age_mean - age_error }
      let(:age_max){ age_mean + age_error }
      it { expect(subject).to be_eql("50 (5)") }
      context "with specified unit" do
        let(:unit){ "a" }
        let(:scale){ 1 }
        it { expect(specimen.age_in_text(:unit => unit, :scale => scale)).to be_eql("50000.0 (5000.0)") }
      end
      context "scale blank" do
        let(:unit){ "a" }
        let(:scale){ nil }
        it { expect(specimen.age_in_text(:unit => unit, :scale => scale)).to be_eql("50000 (5000)") }
      end
    end

    context "without min" do
      let(:age_min){ nil }
      it { expect(subject).to be_eql("<55")}
    end

    context "without max" do
      let(:age_max){ nil }
      it { expect(subject).to be_eql(">45")}
    end

    context "without min and max" do
      let(:age_min){ nil }
      let(:age_max){ nil }
      it { expect(subject).to be_nil}
    end
  end

  describe "#delete_table_analysis" do
    subject { specimen.send(:delete_table_analysis, analysis_1) }
    let(:specimen) { FactoryGirl.create(:specimen) }
    let(:analysis_1) { FactoryGirl.create(:analysis, specimen_id: specimen.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, specimen_id: specimen.id) }
    let(:table_analysis_1) { FactoryGirl.create(:table_analysis, table: table, specimen: specimen, analysis: analysis_1, priority: 1) }
    let(:table_analysis_2) { FactoryGirl.create(:table_analysis, table: table, specimen: specimen, analysis: analysis_2, priority: 2) }
    let(:table) { FactoryGirl.create(:table) }
    before do
      table_analysis_1
      table_analysis_2
    end
    it { expect{ subject }.to change(TableAnalysis, :count).from(2).to(1) }
    it { subject; expect(TableAnalysis.exists?(analysis_id: analysis_2.id)).to eq true }
  end

  describe "#set_specimen_custom_attributes" do
    subject { specimen.set_specimen_custom_attributes }
    let(:specimen) { FactoryGirl.create(:specimen) }
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
      context "specimen is not associate custom_attribute" do
        it { expect(subject.size).to eq(CustomAttribute.count) }
        it { expect(subject[0].custom_attribute_id).to eq(custom_attribute_2.id) }
        it { expect(subject[0].persisted?).to eq false }
        it { expect(subject[1].custom_attribute_id).to eq(custom_attribute_1.id) }
        it { expect(subject[1].persisted?).to eq false }
      end
      context "specimen associate custom_attribute" do
        before { FactoryGirl.create(:specimen_custom_attribute, specimen_id: specimen.id, custom_attribute_id: custom_attribute_1.id) }
        it { expect(subject.size).to eq (CustomAttribute.count) }
        it { expect(subject[0].custom_attribute_id).to eq(custom_attribute_2.id) }
        it { expect(subject[0].persisted?).to eq false }
        it { expect(subject[1].custom_attribute_id).to eq(custom_attribute_1.id) }
        it { expect(subject[1].persisted?).to eq true }
      end
    end
  end

  describe "#ghost" do
    let(:specimen) { FactoryGirl.build(:specimen, quantity: quantity) }
    context "quantity is null" do
      let(:quantity) { nil }
      it { expect(specimen).to_not be_ghost }
    end
    context "quantity greater than zero" do
      let(:quantity) { 1 }
      it { expect(specimen).to_not be_ghost }
    end
    context "quantity equals zero" do
      let(:quantity) { 0 }
      it { expect(specimen).to_not be_ghost }
    end
    context "quantity less than zero" do
      let(:quantity) { -1 }
      it { expect(specimen).to be_ghost }
    end
  end

  describe "validates" do
  
    shared_examples_for "length_check" do
      context "is 255 characters" do
        let(:value) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:value) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
    end
    
    describe "name" do
      let(:obj) { FactoryGirl.build(:specimen, name: value) }
      it_should_behave_like "length_check"
      context "is presence" do
        let(:value) { "sample_obj_name" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:value) { "" }
        it { expect(obj).not_to be_valid }
      end
      context "uniqueness" do
        before { FactoryGirl.create(:specimen, name: "ユニークストーン", box_id: box.id) }
        let(:box) { FactoryGirl.create(:box) }
        let(:specimen) { FactoryGirl.build(:specimen, name: name, box_id: id) }
        let(:box2) { FactoryGirl.create(:box, name: "box2" ) }
        context "specimenのnameとbox_idが違う" do
          let(:name) { "aaaaaaaa" }
          let(:id) { box2.id }
          it { expect(specimen).to be_valid }
        end
        context "specimenのnameが同じでbox_idが違う" do
          let(:name) { "ユニークストーン" }
          let(:id) { box2.id }
          it { expect(specimen).to be_valid }
        end
        context "specimenのbox_idが同じでnameが違う" do
          let(:name) { "aaaaaaaa" }
          let(:id) { box.id }
          it { expect(specimen).to be_valid }
        end
        context "specimenのnameとbox_idが同じ" do
          let(:name) { "ユニークストーン" }
          let(:id) { box.id }
          it { expect(specimen).to be_valid }
        end
      end
    end
    
    describe "parent_id" do
      let(:parent_specimen) { FactoryGirl.create(:specimen) }
      let(:specimen) { FactoryGirl.create(:specimen, parent_id: parent_id) }
      let(:child_specimen) { FactoryGirl.create(:specimen, parent_id: specimen.id) }
      let(:user) { FactoryGirl.create(:user) }
      before do
        User.current = user
        parent_specimen
        specimen
        child_specimen
      end
      context "is nil" do
        let(:parent_id) { nil }
        it { expect(specimen).to be_valid }
      end
      context "is present" do
        let(:parent_id) { parent_specimen.id }
        context "and parent_id equal self.id" do
          before { specimen.parent_id = specimen.id }
          it { expect(specimen).not_to be_valid }
        end
        context "and parent_id equal child_box.id" do
          before { specimen.parent_id = child_specimen.id }
          it { expect(specimen).not_to be_valid }
        end
        context "and valid id" do
          it { expect(specimen).to be_valid }
        end
      end
    end
    
    describe "igsn", :current => true do
      let(:obj) { FactoryGirl.build(:specimen, igsn: igsn) }
      context "9桁の場合" do
        let(:igsn) { "abcd12345" }
        it { expect(obj).to be_valid }
      end
      context "10桁の場合" do
        let(:igsn) { "abcd123456" }
        it { expect(obj).not_to be_valid }
      end
      context "uniqueではない場合" do
        before { FactoryGirl.create(:specimen, igsn: "123456789") }
        let(:obj) { FactoryGirl.build(:specimen, name: "samplename2", igsn: "123456789") }
        it { expect(obj).not_to be_valid }
      end

      context "Unlinked" do
        before { FactoryGirl.create(:specimen, igsn: "") }
        let(:obj) { FactoryGirl.build(:specimen, name: "samplename2", igsn: "") }
        it { expect(obj).to be_valid }
      end

      context "allow_nil" do
        let(:igsn) { nil }
        it { expect(obj).to be_valid }
      end
      context "allow_blank" do
        let(:igsn) { "" }
        it { expect(obj).to be_valid }
      end

    end
    
    describe "age_min" do
      let(:obj) { FactoryGirl.build(:specimen, age_min: age_min) }
      context "数値の場合" do
        context "整数" do
          let(:age_min) { 1 }
          it { expect(obj).to be_valid }
        end
        context "小数点以下を含む" do
          let(:age_min) { 3.5 }
          it {expect(obj).to be_valid}
        end
      end
      context "文字列の場合" do
        let(:age_min) { "あいうえお" }
        it { expect(obj).not_to be_valid }
      end
      context "allow_nil" do
        let(:age_min) { nil }
        it { expect(obj).to be_valid }
      end
    end
    
    describe "age_max" do
      let(:obj) { FactoryGirl.build(:specimen, age_max: age_max) }
      context "数値の場合" do
        context "整数" do
          let(:age_max) { 11 }
          it { expect(obj).to be_valid }
        end
        context "小数点以下を含む" do
          let(:age_max) { 3.5 }
          it {expect(obj).to be_valid}
        end
      end
      context "文字列の場合" do
        let(:age_max) { "あいうえお" }
        it { expect(obj).not_to be_valid }
      end
      context "allow_nil" do
        let(:obj) { FactoryGirl.build(:specimen, age_max: nil) }
        it { expect(obj).to be_valid }
      end
    end
    
    describe "age_unit" do
      let(:obj) { FactoryGirl.build(:specimen, age_unit: value) }
      it_should_behave_like "length_check"
    end
    
    describe "size" do
      let(:obj) { FactoryGirl.build(:specimen, size: value) }
      it_should_behave_like "length_check"
    end
    
    describe "size_unit" do
      let(:obj) { FactoryGirl.build(:specimen, size_unit: value) }
      it_should_behave_like "length_check"
    end
    
    describe "collector" do
      let(:obj) { FactoryGirl.build(:specimen, collector: value) }
      it_should_behave_like "length_check"
    end
    
    describe "collector_detail" do
      let(:obj) { FactoryGirl.build(:specimen, collector_detail: value) }
      it_should_behave_like "length_check"
    end
    
    describe "collection_date_precision" do
      let(:obj) { FactoryGirl.build(:specimen, collection_date_precision: value) }
      it_should_behave_like "length_check"
    end
  end
end
