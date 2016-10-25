require "spec_helper"

describe Specimen do

  describe ".full_analyses", :current => true do
    let(:specimen){ FactoryGirl.create(:specimen) }
    let(:specimen1) { FactoryGirl.create(:specimen, parent_id: specimen.id) }
    let(:specimen2) { FactoryGirl.create(:specimen, parent_id: specimen1.id) }
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
    it { expect(specimen1.analyses.count).to eq 2 }
    it { expect(specimen2.analyses.count).to eq 2 }
    it { expect(specimen.full_analyses.count).to eq 4 }
  end

  describe ".to_pml" do
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

  describe "#quantity_history" do
    let(:time) { Time.new(2016, 11,12) }
    let!(:specimen1) { FactoryGirl.create(:specimen, divide_flg: true) }
    let!(:specimen2) { FactoryGirl.create(:specimen, divide_flg: true, parent_id: specimen1.id) }
    let!(:specimen3) { FactoryGirl.create(:specimen, divide_flg: true, parent_id: specimen2.id) }
    let!(:divide1) { FactoryGirl.create(:divide, updated_at: time) }
    let!(:divide2) { FactoryGirl.create(:divide, updated_at: time + 1.day, before_specimen_quantity: specimen_quantity1) }
    let!(:divide3) { FactoryGirl.create(:divide, updated_at: time + 2.days, before_specimen_quantity: specimen_quantity3) }
    let!(:specimen_quantity1) { FactoryGirl.create(:specimen_quantity, specimen: specimen1, divide: divide1, quantity: 100, quantity_unit: "kg") }
    let!(:specimen_quantity2) { FactoryGirl.create(:specimen_quantity, specimen: specimen1, divide: divide2, quantity: 60, quantity_unit: "kg") }
    let!(:specimen_quantity3) { FactoryGirl.create(:specimen_quantity, specimen: specimen2, divide: divide2, quantity: 40, quantity_unit: "kg") }
    let!(:specimen_quantity4) { FactoryGirl.create(:specimen_quantity, specimen: specimen2, divide: divide3, quantity: 20, quantity_unit: "kg") }
    let!(:specimen_quantity5) { FactoryGirl.create(:specimen_quantity, specimen: specimen3, divide: divide3, quantity: 10, quantity_unit: "kg") }
    subject { specimen1.quantity_history }
    it { expect(subject.class).to eq(Hash) }
    it { expect(subject[0].class).to eq(Array) }
    it { expect(subject[0].first.class).to eq(Hash) }
    it "total" do
      expect(subject[0].length).to eq(3)
      expect(subject[0][0][:id]).to eq(divide1.id)
      expect(subject[0][0][:y]).to eq(100000.0)
      expect(subject[0][0][:quantity_str]).to eq("100,000.0(g)")
      expect(subject[0][1][:id]).to eq(divide2.id)
      expect(subject[0][1][:y]).to eq(100000.0)
      expect(subject[0][1][:quantity_str]).to eq("100,000.0(g)")
      expect(subject[0][2][:id]).to eq(divide3.id)
      expect(subject[0][2][:y]).to eq(90000.0)
      expect(subject[0][2][:quantity_str]).to eq("90,000.0(g)")
    end
    it "specimen1" do
      expect(subject[specimen1.id].length).to eq(2)
      expect(subject[specimen1.id][0][:id]).to eq(divide1.id)
      expect(subject[specimen1.id][0][:y]).to eq(100000.0)
      expect(subject[specimen1.id][0][:quantity_str]).to eq("100.0(kg)")
      expect(subject[specimen1.id][1][:id]).to eq(divide2.id)
      expect(subject[specimen1.id][1][:y]).to eq(60000.0)
      expect(subject[specimen1.id][1][:quantity_str]).to eq("60.0(kg)")
    end
    it "specimen2" do
      expect(subject[specimen2.id].length).to eq(2)
      expect(subject[specimen2.id][0][:id]).to eq(divide2.id)
      expect(subject[specimen2.id][0][:y]).to eq(40000.0)
      expect(subject[specimen2.id][0][:quantity_str]).to eq("40.0(kg)")
      expect(subject[specimen2.id][1][:id]).to eq(divide3.id)
      expect(subject[specimen2.id][1][:y]).to eq(20000.0)
      expect(subject[specimen2.id][1][:quantity_str]).to eq("20.0(kg)")
    end
    it "specimen3" do
      expect(subject[specimen3.id].length).to eq(1)
      expect(subject[specimen3.id][0][:id]).to eq(divide3.id)
      expect(subject[specimen3.id][0][:y]).to eq(10000.0)
      expect(subject[specimen3.id][0][:quantity_str]).to eq("10.0(kg)")
    end
  end

  describe "#divided_loss" do
    before do
      @specimen = FactoryGirl.create(:specimen, quantity: 100, quantity_unit: "kg")
      @specimen.quantity = quantity
      @specimen.quantity_unit = quantity_unit
      @specimen.children.build(quantity: 30, quantity_unit: "kg")
      @specimen.children.build(quantity: 20, quantity_unit: "kg")
    end
    subject { @specimen.divided_loss }
    context "non loss" do
      let(:quantity) { 50 }
      let(:quantity_unit) { "kg" }
      it { expect(subject).to eq(0.to_d) }
    end
    context "loss" do
      let(:quantity) { 40 }
      let(:quantity_unit) { "kg" }
      it { expect(subject).to eq(10000.0.to_d) }
    end
    context "over" do
      let(:quantity) { 60 }
      let(:quantity_unit) { "kg" }
      it { expect(subject).to eq(-10000.0.to_d) }
    end
  end

  describe "#divide_save" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      User.current = user
      @specimen = FactoryGirl.create(:specimen, quantity: 100, quantity_unit: "kg")
      @specimen_quantitiy = @specimen.specimen_quantities.last
      @specimen.quantity = 50
      @specimen.comment = "comment"
      @specimen_child1 = @specimen.children.build(name: "a", quantity: 30, quantity_unit: "kg")
      @specimen_child2 = @specimen.children.build(name: "b", quantity: 20, quantity_unit: "kg")
    end
    describe "update parent_specimen" do
      it { expect{ @specimen.divide_save }.to change{ Specimen.find(@specimen.id).quantity }.from(100).to(50) }
    end
    describe "create child_specimens" do
      it { expect{ @specimen.divide_save }.to change{ Specimen.find(@specimen.id).children.count }.by(2) }
      it do
        @specimen.divide_save
        expect(@specimen_child1.name).to eq("a")
        expect(@specimen_child1.quantity).to eq(30)
        expect(@specimen_child1.quantity_unit).to eq("kg")
        expect(@specimen_child2.name).to eq("b")
        expect(@specimen_child2.quantity).to eq(20)
        expect(@specimen_child2.quantity_unit).to eq("kg")
      end
    end
    describe "create specimen_quantities" do
      it { expect{ @specimen.divide_save }.to change{ SpecimenQuantity.count }.by(3) }
      it { expect{ @specimen.divide_save }.to change{ @specimen.specimen_quantities.count }.by(1) }
      it { expect{ @specimen.divide_save }.to change{ @specimen_child1.specimen_quantities.count }.by(1) }
      it { expect{ @specimen.divide_save }.to change{ @specimen_child2.specimen_quantities.count }.by(1) }
    end
    describe "create divide" do
      it { expect{ @specimen.divide_save }.to change{ Divide.count }.by(1) }
      it do
        @specimen.divide_save
        divide = Divide.find_by(before_specimen_quantity_id: @specimen_quantitiy.id)
        expect(divide.log).to eq("comment")
        expect(divide.divide_flg).to eq(true)
        expect(divide.specimen_quantities).to\
          match_array([
            @specimen.specimen_quantities.last,
            @specimen_child1.specimen_quantities.last,
            @specimen_child2.specimen_quantities.last
          ])
      end
    end
  end

  describe "build_specimen_quantity" do
    let(:specimen) { FactoryGirl.create(:specimen, quantity: 100, quantity_unit: "kg") }
    let(:divide) { FactoryGirl.create(:divide) }
    before do
      @specimen_quantity = specimen.specimen_quantities.last
    end
    context "argument is 0" do
      subject { specimen.build_specimen_quantity }
      it { expect(subject.specimen).to eq(specimen) }
      it { expect(subject.quantity).to eq(100) }
      it { expect(subject.quantity_unit).to eq("kg") }
      it { expect(subject.divide).to be_new_record }
      it { expect(subject.divide.before_specimen_quantity).to eq(@specimen_quantity) }
      it do
        expect(specimen).to receive(:build_divide)
        subject
      end
    end
    context "argument is 1" do
      subject { specimen.build_specimen_quantity(divide) }
      it { expect(subject.specimen).to eq(specimen) }
      it { expect(subject.quantity).to eq(100) }
      it { expect(subject.quantity_unit).to eq("kg") }
      it { expect(subject.divide).to eq(divide) }
      it { expect(subject.divide.before_specimen_quantity).to eq(divide.before_specimen_quantity) }
      it do
        expect(specimen).not_to receive(:build_divide)
        subject
      end
    end
  end

  describe "point_info" do
    let(:before_specimen) { FactoryGirl.create(:specimen, quantity: 100, quantity_unit: "kg") }
    let(:before_specimen_quantity) { FactoryGirl.create(:specimen_quantity, specimen: before_specimen, quantity: 100, quantity_unit: "kg") }
    let(:divide) { FactoryGirl.create(:divide, before_specimen_quantity: before_specimen_quantity, updated_at: time, divide_flg: divide_flg, log: "log") }
    let(:specimen) { FactoryGirl.create(:specimen, quantity: 100, quantity_unit: "kg") }
    let(:time) { Time.new(2016, 11,12) }
    let(:divide_flg) { true }
    subject { specimen.send(:point_info, divide, 100000.0, "100(kg)") }
    context "divide_flg true" do
      let(:divide_flg) { true }
      it do
        expect(subject.class).to eq(Hash)
        expect(subject[:id]).to eq(divide.id)
        expect(subject[:x]).to eq(divide.chart_updated_at)
        expect(subject[:y]).to eq(100000.0)
        expect(subject[:date_str]).to eq("2016/11/12 00:00:00")
        expect(subject[:quantity_str]).to eq("100(kg)")
        expect(subject[:before_specimen_name]).to eq(before_specimen.name)
        expect(subject[:comment]).to eq("log")
      end
    end
    context "divide_flg false" do
      let(:divide_flg) { false }
      it do
        expect(subject.class).to eq(Hash)
        expect(subject[:id]).to eq(divide.id)
        expect(subject[:x]).to eq(divide.chart_updated_at)
        expect(subject[:y]).to eq(100000.0)
        expect(subject[:date_str]).to eq("2016/11/12 00:00:00")
        expect(subject[:quantity_str]).to eq("100(kg)")
        expect(subject[:before_specimen_name]).to be_nil
        expect(subject[:comment]).to eq("log")
      end
    end
  end

  describe "new_children" do
    let!(:specimen) { FactoryGirl.create(:specimen) }
    let!(:specimen_child) { FactoryGirl.create(:specimen, parent_id: specimen.id) }
    before do
      @new_specimen = specimen.children.build
    end
    subject { specimen.send(:new_children) }
    it { expect(subject).to match_array([@new_specimen]) }
  end

  describe "self_and_new_children" do
    let!(:specimen) { FactoryGirl.create(:specimen) }
    let!(:specimen_child) { FactoryGirl.create(:specimen, parent_id: specimen.id) }
    before do
      @new_specimen = specimen.children.build
    end
    subject { specimen.send(:self_and_new_children) }
    it { expect(subject).to match_array([specimen, @new_specimen]) }
  end

  describe "build_divide" do
    let!(:specimen) { FactoryGirl.create(:specimen, name: "specimenA", quantity: 100, quantity_unit: "kg", divide_flg: divide_flg, comment: "comment") }
    before do
      specimen.quantity = 200
      specimen.quantity_unit = "g"
    end
    subject { specimen.send(:build_divide) }
    context "divide_flg true" do
      let(:divide_flg) { true }
      it do
        expect(subject.before_specimen_quantity).to be_nil
        expect(subject.divide_flg).to eq(true)
        expect(subject.log).to eq("comment")
      end
    end
    context "divide_flg nil" do
      let(:divide_flg) { nil }
      it do
        expect(subject.before_specimen_quantity).to_not be_nil
        expect(subject.before_specimen_quantity).to eq(specimen.specimen_quantities.last)
        expect(subject.divide_flg).to eq(false)
        expect(subject.log).to eq("[specimenA] 100.0(kg) -> 200.0(g)")
      end
    end
  end

  describe "build_log" do
    let!(:specimen) { FactoryGirl.create(:specimen, name: "specimenA", quantity: 100, quantity_unit: "kg", divide_flg: divide_flg, comment: "comment") }
    before do
      specimen.quantity = 200
      specimen.quantity_unit = "g"
    end
    subject { specimen.send(:build_log) }
    context "divide_flg true" do
      let(:divide_flg) { true }
      it { expect(subject).to eq("comment") }
    end
    context "divide_flg false" do
      let(:divide_flg) { false }
      context "new_record" do
        let!(:specimen) { FactoryGirl.build(:specimen, name: "specimenA", divide_flg: divide_flg, comment: "comment") }
        it { expect(subject).to eq("[specimenA] new specimen.") }
      end
      context "non new_record" do
        it { expect(subject).to eq("[specimenA] 100.0(kg) -> 200.0(g)") }
      end
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

  describe "before_save" do
    describe "build_specimen_quantity" do
      let(:user) { FactoryGirl.create(:user) }
      let(:specimen) { FactoryGirl.create(:specimen, quantity: 100, quantity_unit: "kg") }
      let(:quantity) { 100 }
      let(:quantity_unit) { "kg" }
      let(:divide_flg) { false }
      before do
        User.current = user
        @specimen = specimen
        @specimen.quantity = quantity
        @specimen.quantity_unit = quantity_unit
        @specimen.divide_flg = divide_flg
      end
      context "divide_flg true" do
        let(:quantity) { 200 }
        let(:quantity_unit) { "g" }
        let(:divide_flg) { true }
        it do
          expect(@specimen).to_not receive(:build_specimen_quantity)
          @specimen.save!
        end
      end
      context "divide_flg false" do
        context "new_record" do
          let(:specimen) { FactoryGirl.build(:specimen, quantity: 100, quantity_unit: "kg") }
          it do
            expect(@specimen).to receive(:build_specimen_quantity)
            @specimen.save!
          end
        end
        context "non new_record" do
          context "quantity_changed" do
            let(:quantity) { 200 }
            it do
              expect(@specimen).to receive(:build_specimen_quantity)
              @specimen.save!
            end
          end
          context "not quantity_changed" do
            context "quantity_unit_changed" do
              let(:quantity_unit) { "g" }
              it do
                expect(@specimen).to receive(:build_specimen_quantity)
                @specimen.save!
              end
            end
            context "not quantity_unit_changed" do
              it do
                expect(@specimen).to_not receive(:build_specimen_quantity)
                @specimen.save!
              end
            end
          end
        end
      end
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

    describe "to_bibtex" do
      subject {obj.to_bibtex}
      let(:obj) { FactoryGirl.create(:specimen) }
      it { expect(subject).to match(/^\@article/) }
    end
    
    describe "igsn" do
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

    describe "quantity" do
      let(:obj) { FactoryGirl.build(:specimen, quantity: quantity, quantity_unit: quantity_unit) }
      let(:quantity_unit) { "kg" }
      context "num" do
        let(:quantity){ "1" }
        it { expect(obj).to be_valid }
        context "0" do
          let(:quantity){ "0" }
          it { expect(obj).to be_valid }
        end
        context "-1" do
          let(:quantity){ "-1" }
          it { expect(obj).not_to be_valid }
        end
      end
      context "str" do
        let(:quantity){ "a" }
        it { expect(obj).not_to be_valid }
      end
      context "blank" do
        let(:quantity){ "" }
        context "quantity_unit present" do
          it { expect(obj).not_to be_valid }
        end
        context "quantity_unit blank" do
          let(:quantity_unit) { "" }
          it { expect(obj).to be_valid }
        end
      end
    end

    describe "quantity" do
      let(:obj) { FactoryGirl.build(:specimen, quantity: quantity, quantity_unit: quantity_unit) }
      let(:quantity){ "1" }
      context "exists" do
        let(:quantity_unit) { "kgram" }
        it { expect(obj).to be_valid }
      end
      context "not exists" do
        let(:quantity_unit) { "kglam" }
        it { expect(obj).not_to be_valid }
      end
      context "blank" do
        let(:quantity_unit) { "" }
        context "quantity present" do
          it { expect(obj).not_to be_valid }
        end
        context "quantity blank" do
          let(:quantity) { "" }
          it { expect(obj).to be_valid }
        end
      end
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
