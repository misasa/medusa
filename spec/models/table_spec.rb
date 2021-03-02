# -*- coding: utf-8 -*-
require "spec_helper"

describe "Table" do
  let(:table) { FactoryBot.create(:table, measurement_category: measurement_category) }
  let(:measurement_category) { FactoryBot.create(:measurement_category, unit: unit) }
  let(:unit) { FactoryBot.create(:unit) }
  let(:category_measurement_item) { FactoryBot.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
  let(:measurement_item) { FactoryBot.create(:measurement_item, unit: unit) }
  let(:table_specimen) { FactoryBot.create(:table_specimen, table: table, specimen: specimen) }
  let(:specimen) { FactoryBot.create(:specimen) }
  let(:analysis) { FactoryBot.create(:analysis, specimen: specimen) }
  let(:chemistry) { FactoryBot.create(:chemistry, analysis: analysis, unit: unit, measurement_item: measurement_item) }
  let(:sub_specimen) { FactoryBot.create(:specimen, parent_id: specimen.id) }
  let(:sub_analysis) { FactoryBot.create(:analysis, specimen: sub_specimen) }
  let(:sub_chemistry) { FactoryBot.create(:chemistry, analysis: sub_analysis, unit: unit, measurement_item: measurement_item) }

  describe "validates" do
    describe "age_unit" do
      subject { table.valid? }
      let(:table) { FactoryBot.build(:table, with_age: with_age, age_unit: age_unit) }
      let(:with_age) { true }
      let(:age_unit) { "Ka" }
      context "is present" do
        context "with_age is true" do
          it { expect(subject).to eq true }
        end
        context "with_age is false" do
          let(:with_age) { false }
          it { expect(subject).to eq true }
        end
      end
      context "is blank" do
        let(:age_unit) { "" }
        context "with_age is true" do
        it { expect(subject).to eq false }
        end
        context "with_age is false" do
          let(:with_age) { false }
          it { expect(subject).to eq true }
        end
      end
    end
    describe "age_scale" do
      subject { table.valid? }
      let(:table) { FactoryBot.build(:table, with_age: with_age, age_scale: age_scale) }
      let(:with_age) { true }
      let(:age_scale) { 0 }
      context "is present" do
        context "with_age is true" do
          it { expect(subject).to eq true }
        end
        context "with_age is false" do
          let(:with_age) { false }
          it { expect(subject).to eq true }
        end
      end
      context "is blank" do
        let(:age_scale) { nil }
        context "with_age is true" do
        it { expect(subject).to eq true }
        end
        context "with_age is false" do
          let(:with_age) { false }
          it { expect(subject).to eq true }
        end
      end
    end
  end

  describe "recursive", :current => true do
    before do
      specimen
      analysis
      chemistry
      sub_specimen
      sub_analysis
      sub_chemistry
      table
      table_specimen
    end
    it { expect(table.full_specimens.count).to be_eql 2}
    it { expect(table.analyses.count).to be_eql 2}
    it { expect(table.analyses.count).to be_eql 2}
    it { expect(table.chemistries.count).to be_eql 2}
  end

  describe "publish!" do
    subject { table.publish! }
    before do
      specimen
      allow(specimen).to receive(:publish!)
      analysis
      chemistry
      sub_specimen
      allow(sub_specimen).to receive(:publish!)
      sub_analysis
      sub_chemistry
      table
      table_specimen
    end
    it { expect{ subject }.not_to raise_error }
    it { expect{ subject }.to change{table.published}.from(be_falsey).to(be_truthy) }
  end

  describe "selected_analyses", :current => true do
    before do
      specimen
      analysis
      chemistry
      sub_specimen
      sub_analysis
      sub_chemistry
      #measurement_category
      #measurement_item
      #category_measurement_item
      table
      table_specimen
   end
    it do
      expect(table.selected_analyses).to be_an_instance_of(Array)
    end
    #it { expect(table.analyses.count).to be_eql 2}
    #it { expect(table.selected_analyses.count).to be_eql 1}
    #it { expect(table.chemistries.count).to be_eql 2}
  end

  describe "refresh" do
    before do
      specimen
      analysis
      chemistry
      table
      table_specimen
      sub_specimen
      sub_analysis
      sub_chemistry
      table.refresh
    end
    it { expect(table.full_specimens.count).to be_eql 2}
    it { expect(table.analyses.count).to be_eql 2}
    it { expect(table.chemistries.count).to be_eql 2}
    it { expect(table.table_analyses.count).to be_eql 2}
  end

  describe "#each" do
    context "table not link category_measurement_item" do
      it { expect { |b| table.each(&b) }.not_to yield_control }
    end
    context "table linked 1 category_measurement_item" do
      before do
        category_measurement_item_1
        analysis
        chemistry
        table
        table_specimen
        allow(Table::Row).to receive(:new).with(table, category_measurement_item_1, [chemistry]).and_return(:row_1)
      end
      let(:category_measurement_item_1) { FactoryBot.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
      it { expect { |b| table.each(&b) }.to yield_control.once }
      it { expect { |b| table.each(&b) }.to yield_successive_args(:row_1) }
    end
    context "table linked 2 category_measurement_items" do
      before do
        category_measurement_item_1
        category_measurement_item_2
        analysis
        chemistry
        table
        table_specimen
        allow(Table::Row).to receive(:new).with(table, category_measurement_item_1, [chemistry]).and_return(:row_1)
        allow(Table::Row).to receive(:new).with(table, category_measurement_item_2, [chemistry]).and_return(:row_2)
      end
      let(:category_measurement_item_1) { FactoryBot.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
      let(:category_measurement_item_2) { FactoryBot.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
      it { expect { |b| table.each(&b) }.to yield_control.twice }
      it { expect { |b| table.each(&b) }.to yield_successive_args(:row_2, :row_1) }
    end
  end

  describe "#method_descriptions" do
    subject { table.method_descriptions }
    context "table has 0 description" do
      it { expect(subject).to be_blank }
    end
    context "table has 1 description" do
      before do
        table.method_sign(technique_1, device_1)
      end
      let(:technique_1) { FactoryBot.create(:technique, name: "technique_1") }
      let(:device_1) { FactoryBot.create(:device, name: "device_1") }
      it { expect(subject).to eq({"a" => "#{technique_1.name} on #{device_1.name}"}) }
    end
    context "table has 2 descriptions" do
      before do
        table.method_sign(technique_1, device_1)
        table.method_sign(technique_2, device_2)
      end
      let(:technique_1) { FactoryBot.create(:technique, name: "technique_1") }
      let(:technique_2) { FactoryBot.create(:technique, name: "technique_2") }
      let(:device_1) { FactoryBot.create(:device, name: "device_1") }
      let(:device_2) { FactoryBot.create(:device, name: "device_2") }
      it { expect(subject).to eq({"a" => "#{technique_1.name} on #{device_1.name}", "b" => "#{technique_2.name} on #{device_2.name}"}) }
    end
  end

  describe "#method_sign", :current => true do
    context "method call once" do
      subject { table.method_sign(technique, device) }
      let(:technique) { FactoryBot.create(:technique) }
      let(:device) { FactoryBot.create(:device) }
      context "technique is nil" do
        let(:technique) { nil }
        context "device is nil" do
          let(:device) { nil }
          it { expect(subject).to be_nil }
        end
        context "device is present" do
          it { expect(subject).to eq "a" }
          it { subject; expect(table.send(:methods_hash)).to eq({ [nil, device.id] => {:sign => "a", :technique_id => nil, :device_id=> device.id, :description => "on #{device.name}"} }) }
        end
      end
      context "technique is present" do
        context "device is nil" do
          let(:device) { nil }
          it { expect(subject).to eq "a" }
          it { subject; expect(table.send(:methods_hash)).to eq({ [technique.id, nil] => {:sign => "a", :technique_id => technique.id, :device_id => nil, :description => "#{technique.name} "} }) }
        end
        context "device is present" do
          it { expect(subject).to eq "a" }
          it { subject; expect(table.send(:methods_hash)).to eq({ [technique.id, device.id] => {:sign => "a", :technique_id => technique.id, :device_id => device.id, :description => "#{technique.name} on #{device.name}"} }) }
        end
      end
    end
    context "method call twice" do
      before { table.method_sign(technique_1, device_1) }
      subject { table.method_sign(technique_2, device_2) }
      let(:technique_1) { FactoryBot.create(:technique, name: "technique_1") }
      let(:technique_2) { FactoryBot.create(:technique, name: "technique_2") }
      let(:device_1) { FactoryBot.create(:device, name: "device_1") }
      let(:device_2) { FactoryBot.create(:device, name: "device_2") }
      it { expect(subject).to eq "b" }
      it do
        subject
        expect(table.send(:methods_hash)).to eq({
          [technique_1.id, device_1.id] => {:sign => "a", :technique_id => technique_1.id, :device_id => device_1.id, :description => "#{technique_1.name} on #{device_1.name}"},
          [technique_2.id, device_2.id] => {:sign => "b", :technique_id => technique_2.id, :device_id => device_2.id, :description => "#{technique_2.name} on #{device_2.name}"}
        })
      end
    end
  end

  describe "#priority" do
    subject { table.priority(analysis_id) }
    let(:analysis_id) { analysis_2.id }
    let(:analysis_1) { FactoryBot.create(:analysis, specimen: specimen) }
    let(:analysis_2) { FactoryBot.create(:analysis, specimen: specimen) }
    let(:table_analysis_1) { FactoryBot.create(:table_analysis, table: table, specimen: specimen, analysis: analysis_1, priority: 1) }
    let(:table_analysis_2) { FactoryBot.create(:table_analysis, table: table, specimen: specimen, analysis: analysis_2, priority: 2) }
    before do
      table_analysis_1
      table_analysis_2
    end
    context "argument is analysis_2.id" do
      it { expect(subject).to eq(table_analysis_2.priority) }
    end
    context "argument is analysis_1.id" do
      let(:analysis_id) { analysis_1.id }
      it { expect(subject).to eq(table_analysis_1.priority) }
    end
  end

end

describe "after_remove specimens" do
  let(:bib) { FactoryBot.create(:bib) }
  let(:table) { FactoryBot.create(:table, measurement_category: measurement_category) }
  let(:table_2) { FactoryBot.create(:table, measurement_category: measurement_category) }
  let(:measurement_category) { FactoryBot.create(:measurement_category, unit: unit) }
  let(:unit) { FactoryBot.create(:unit, name: "gram_per_gram", conversion: 1) }
  let(:specimen_1) { FactoryBot.create(:specimen) }
  let(:specimen_2) { FactoryBot.create(:specimen) }
  subject { table.specimens.destroy(specimen_2) }
  context "does not remove specimen from bib" do
    before do
      bib.tables << table
      table.specimens << specimen_1
      table.specimens << specimen_2
      subject
    end
    it { expect(bib.specimens.count).to be_eql(2) }
  end

  context "does not remove specimen from bib" do
    before do
      bib.tables << table
      bib.tables << table_2
      table.specimens << specimen_1
      table.specimens << specimen_2
      table_2.specimens << specimen_1
      table_2.specimens << specimen_2
      subject
    end
    it { expect(bib.specimens.count).to be_eql(2) }
  end

end


describe "table" do
  let(:bib) { FactoryBot.create(:bib) }
  let(:table) { FactoryBot.create(:table, measurement_category: measurement_category) }
  let(:table_2) { FactoryBot.create(:table, measurement_category: measurement_category) }
  let(:measurement_category) { FactoryBot.create(:measurement_category, unit: unit) }
  let(:unit) { FactoryBot.create(:unit, name: "gram_per_gram", conversion: 1) }
  let(:specimen_1) { FactoryBot.create(:specimen) }
  let(:specimen_2) { FactoryBot.create(:specimen) }
  let(:specimen_3) { FactoryBot.create(:specimen) }
#  subject { table.specimens.destroy(specimen_2) }
  context "takes over specimen from bib" do
    before do
      bib.specimens << specimen_1
      bib.specimens << specimen_2
      bib.specimens << specimen_3
      bib.tables << table
    end
    it { expect(bib.specimens.count).to be_eql(3) }
    it { expect(table.specimens.count).to be_eql(3) }
  end

  context "with flag_ingore = true does not take over specimen from bib" do
    before do
      bib.specimens << specimen_1
      bib.specimens << specimen_2
      bib.specimens << specimen_3
      table.flag_ignore_take_over_specimen = true
      bib.tables << table
    end
    it { expect(bib.specimens.count).to be_eql(3) }
    it { expect(table.specimens.count).to be_eql(0) }
  end

end
describe "Table::Row" do
  let(:row) { Table::Row.new(table, category_measurement_item, [chemistry]) }
  let(:table) { FactoryBot.create(:table, measurement_category: measurement_category) }
  let(:measurement_category) { FactoryBot.create(:measurement_category, unit: unit) }
  let(:unit) { FactoryBot.create(:unit, name: "gram_per_gram", conversion: 1) }
  let(:category_measurement_item) { FactoryBot.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
  let(:measurement_item) { FactoryBot.create(:measurement_item, unit: unit, nickname: "測定１", display_in_html: "[A]", display_in_tex: "\abundance{A}") }
  let(:specimen) { FactoryBot.create(:specimen) }
  let(:analysis) { FactoryBot.create(:analysis, specimen: specimen) }
  let(:chemistry) { FactoryBot.create(:chemistry, analysis: analysis, unit: unit, measurement_item: measurement_item) }
  before do
    Alchemist.setup
    Alchemist.register(:mass, unit.name.to_sym, 1.to_d / unit.conversion)
  end

  describe "#name" do
    subject { row.name(type) }
    let(:type) { nil }
    context "type is nil" do
      it { expect(subject).to eq(measurement_item.nickname) }
    end
    context "type is html" do
      let(:type) { :html }
      it { expect(subject).to eq(measurement_item.display_in_html) }
    end
    context "type is tex" do
      let(:type) { :tex }
      it { expect(subject).to eq(measurement_item.display_in_tex) }
    end
  end

  describe "#symbol" do
    subject { row.symbol }

    context "table linked 2 chemistries without device & technique pair" do
      let(:row) { Table::Row.new(table, category_measurement_item, [chemistry_1, chemistry_2]) }
      let(:table_specimen_1) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_1) }
      let(:table_specimen_2) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_2) }
      let(:specimen_1) { FactoryBot.create(:specimen) }
      let(:specimen_2) { FactoryBot.create(:specimen) }
      let(:analysis_1) { FactoryBot.create(:analysis, specimen: specimen_1, device: nil, technique: nil) }
      let(:analysis_2) { FactoryBot.create(:analysis, specimen: specimen_2, device: nil, technique: nil) }
      let(:chemistry_1) { FactoryBot.create(:chemistry, analysis: analysis_1, unit: unit, measurement_item: measurement_item, value: 1) }
      let(:chemistry_2) { FactoryBot.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 2) }
      before do
        table_specimen_1
        table_specimen_2
      end
      it { expect(subject.present?).to eq(false) }

    end

    context "table linked 2 chemistries with same device & technique pair" do
      let(:row) { Table::Row.new(table, category_measurement_item, [chemistry_1, chemistry_2]) }
      let(:table_specimen_1) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_1) }
      let(:table_specimen_2) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_2) }
      let(:specimen_1) { FactoryBot.create(:specimen) }
      let(:specimen_2) { FactoryBot.create(:specimen) }
      let(:device_1){ FactoryBot.create(:device) }
      let(:technique_1){ FactoryBot.create(:technique) }
      let(:analysis_1) { FactoryBot.create(:analysis, specimen: specimen_1, device: device_1, technique: technique_1) }
      let(:analysis_2) { FactoryBot.create(:analysis, specimen: specimen_2, device: device_1, technique: technique_1) }
      let(:chemistry_1) { FactoryBot.create(:chemistry, analysis: analysis_1, unit: unit, measurement_item: measurement_item, value: 1) }
      let(:chemistry_2) { FactoryBot.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 2) }
      before do
        table_specimen_1
        table_specimen_2
      end
      it { expect(subject.present?).to eq(true) }
    end

    context "table linked 2 chemistries with same device & technique pair and 1 chemistry without device & techniqu pair" do
      let(:row) { Table::Row.new(table, category_measurement_item, [chemistry_1, chemistry_2, chemistry_3]) }
      let(:measurement_item_2) { FactoryBot.create(:measurement_item, unit: unit, nickname: "測定2", display_in_html: "[B]", display_in_tex: "\abundance{B}") }
      let(:table_specimen_1) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_1) }
      let(:table_specimen_2) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_2) }
      let(:table_specimen_3) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_3) }
      let(:specimen_1) { FactoryBot.create(:specimen) }
      let(:specimen_2) { FactoryBot.create(:specimen) }
      let(:specimen_3) { FactoryBot.create(:specimen) }
      let(:device_1){ FactoryBot.create(:device) }
      let(:technique_1){ FactoryBot.create(:technique) }
      let(:analysis_1) { FactoryBot.create(:analysis, specimen: specimen_1, device: device_1, technique: technique_1) }
      let(:analysis_2) { FactoryBot.create(:analysis, specimen: specimen_2, device: device_1, technique: technique_1) }
      let(:analysis_3) { FactoryBot.create(:analysis, specimen: specimen_3, device: device_1, technique: nil) }
      let(:chemistry_1) { FactoryBot.create(:chemistry, analysis: analysis_1, unit: unit, measurement_item: measurement_item, value: 1) }
      let(:chemistry_2) { FactoryBot.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 2) }
      let(:chemistry_3) { FactoryBot.create(:chemistry, analysis: analysis_3, unit: unit, measurement_item: measurement_item, value: 3) }
      before do
        table_specimen_1
        table_specimen_2
        table_specimen_3
        #table.specimens.destroy(specimen_3)
      end
      it { expect(subject.present?).to eq(false) }
    end


    context "table linked 2 chemistries with same device & technique pair and 1 chemistry without device & techniqu pair and after remove last chemistry" do
      let(:row) { Table::Row.new(table, category_measurement_item, [chemistry_1, chemistry_2, chemistry_3]) }
      let(:measurement_item_2) { FactoryBot.create(:measurement_item, unit: unit, nickname: "測定2", display_in_html: "[B]", display_in_tex: "\abundance{B}") }
      let(:table_specimen_1) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_1) }
      let(:table_specimen_2) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_2) }
      let(:table_specimen_3) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_3) }
      let(:specimen_1) { FactoryBot.create(:specimen) }
      let(:specimen_2) { FactoryBot.create(:specimen) }
      let(:specimen_3) { FactoryBot.create(:specimen) }
      let(:device_1){ FactoryBot.create(:device) }
      let(:technique_1){ FactoryBot.create(:technique) }
      let(:analysis_1) { FactoryBot.create(:analysis, specimen: specimen_1, device: device_1, technique: technique_1) }
      let(:analysis_2) { FactoryBot.create(:analysis, specimen: specimen_2, device: device_1, technique: technique_1) }
      let(:analysis_3) { FactoryBot.create(:analysis, specimen: specimen_3, device: device_1, technique: nil) }
      let(:chemistry_1) { FactoryBot.create(:chemistry, analysis: analysis_1, unit: unit, measurement_item: measurement_item, value: 1) }
      let(:chemistry_2) { FactoryBot.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 2) }
      let(:chemistry_3) { FactoryBot.create(:chemistry, analysis: analysis_3, unit: unit, measurement_item: measurement_item, value: 3) }
      before do
        table_specimen_1
        table_specimen_2
        table_specimen_3
        table.specimens.destroy(specimen_3)
      end
      it { expect(subject.present?).to eq(true) }
    end
    context "table linked 2 chemistries with different device & technique pair" do
      let(:row) { Table::Row.new(table, category_measurement_item, [chemistry_1, chemistry_2]) }
      let(:table_specimen_1) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_1) }
      let(:table_specimen_2) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_2) }
      let(:specimen_1) { FactoryBot.create(:specimen) }
      let(:specimen_2) { FactoryBot.create(:specimen) }
      let(:device_1){ FactoryBot.create(:device) }
      let(:technique_1){ FactoryBot.create(:technique) }
      let(:technique_2){ FactoryBot.create(:technique) }
      let(:analysis_1) { FactoryBot.create(:analysis, specimen: specimen_1, device: device_1, technique: technique_1) }
      let(:analysis_2) { FactoryBot.create(:analysis, specimen: specimen_2, device: device_1, technique: technique_2) }
      let(:chemistry_1) { FactoryBot.create(:chemistry, analysis: analysis_1, unit: unit, measurement_item: measurement_item, value: 1) }
      let(:chemistry_2) { FactoryBot.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 2) }
      before do
        table_specimen_1
        table_specimen_2
      end
      it { expect(subject.present?).to eq(false) }
    end

  end

  describe "#each" do
    context "table not link table_specimen" do
      it { expect { |b| table.each(&b) }.not_to yield_control }
    end
    context "table linked 1 table_specimen" do
      before do
        table_specimen_1
        allow(Table::Cell).to receive(:new).with(row, [chemistry]).and_return(:cell)
      end
      let(:table_specimen_1) { FactoryBot.create(:table_specimen, table: table, specimen: specimen) }
      it { expect { |b| row.each(&b) }.to yield_control.once }
      it { expect { |b| row.each(&b) }.to yield_successive_args(:cell) }
    end
    context "table linked 2 table_specimens" do
      before do
        table_specimen_1
        table_specimen_2
        allow(Table::Cell).to receive(:new).with(row, [chemistry]).and_return(:cell)
      end
      let(:table_specimen_1) { FactoryBot.create(:table_specimen, table: table, specimen: specimen) }
      let(:table_specimen_2) { FactoryBot.create(:table_specimen, table: table, specimen: specimen) }
      it { expect { |b| row.each(&b) }.to yield_control.twice }
      it { expect { |b| row.each(&b) }.to yield_successive_args(:cell, :cell) }
    end
  end

  describe "#mean" do
    subject { row.mean(round_flag) }
    let(:round_flag) { false }
    let(:category_measurement_item) { FactoryBot.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item, scale: scale) }
    let(:scale) { 1 }
    context "round_flag is false" do
      context "table linked 1 chemistry" do
        it { expect(subject).to eq(chemistry.value) }
      end
      context "table linked 2 chemistries" do
        let(:row) { Table::Row.new(table, category_measurement_item, [chemistry_1, chemistry_2]) }
        let(:table_specimen_1) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_1) }
        let(:table_specimen_2) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_2) }
        let(:specimen_1) { FactoryBot.create(:specimen) }
        let(:specimen_2) { FactoryBot.create(:specimen) }
        let(:analysis_1) { FactoryBot.create(:analysis, specimen: specimen_1) }
        let(:analysis_2) { FactoryBot.create(:analysis, specimen: specimen_2) }
        let(:chemistry_1) { FactoryBot.create(:chemistry, analysis: analysis_1, unit: unit, measurement_item: measurement_item, value: 1) }
        let(:chemistry_2) { FactoryBot.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 2) }
        before do
          specimen_1
          analysis_1
          specimen_2
          analysis_2
          table
          table_specimen_1
          table_specimen_2
        end
        it { expect(subject).to eq((chemistry_1.value + chemistry_2.value) / table.chemistries.size) }
      end
    end
    context "round_flag is true" do
      let(:round_flag) { true }
      shared_examples_for 'Table::Row 平均値が指定する有効精度で返されること' do |scale|
        context "table linked 1 chemistry" do
          it { expect(subject).to eq((chemistry.value).round(scale)) }
        end
        context "table linked 2 chemistries" do
          let(:row) { Table::Row.new(table, category_measurement_item, [chemistry_1, chemistry_2]) }
          let(:table_specimen_1) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_1) }
          let(:table_specimen_2) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_2) }
          let(:specimen_1) { FactoryBot.create(:specimen) }
          let(:specimen_2) { FactoryBot.create(:specimen) }
          let(:analysis_1) { FactoryBot.create(:analysis, specimen: specimen_1) }
          let(:analysis_2) { FactoryBot.create(:analysis, specimen: specimen_2) }
          let(:chemistry_1) { FactoryBot.create(:chemistry, analysis: analysis_1, unit: unit, measurement_item: measurement_item, value: 1) }
          let(:chemistry_2) { FactoryBot.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 2) }
          before do
            specimen_1
            analysis_1
            specimen_2
            analysis_2
            table
            table_specimen_1
            table_specimen_2
          end
          it { expect(subject).to eq(((chemistry_1.value + chemistry_2.value) / table.chemistries.size).round(scale)) }
        end
      end
      context "category_measurement_item.scale is 1" do
        it_behaves_like 'Table::Row 平均値が指定する有効精度で返されること', 1
      end
      context "category_measurement_item.scale is 2" do
        let(:scale) { 2 }
        it_behaves_like 'Table::Row 平均値が指定する有効精度で返されること', 2
      end
      context "category_measurement_item.scale is 0" do
        let(:scale) { 0 }
        it_behaves_like 'Table::Row 平均値が指定する有効精度で返されること', 0
      end
    end
  end

  describe "#standard_diviation" do
    subject { row.standard_diviation }
    let(:row) { Table::Row.new(table, category_measurement_item, [chemistry_1, chemistry_2, chemistry_3]) }
    let(:category_measurement_item) { FactoryBot.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item, scale: scale) }
    let(:scale) { 1 }
    let(:table_specimen_1) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_1) }
    let(:table_specimen_2) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_2) }
    let(:table_specimen_3) { FactoryBot.create(:table_specimen, table: table, specimen: specimen_3) }
    let(:specimen_1) { FactoryBot.create(:specimen) }
    let(:specimen_2) { FactoryBot.create(:specimen) }
    let(:specimen_3) { FactoryBot.create(:specimen) }
    let(:analysis_1) { FactoryBot.create(:analysis, specimen: specimen_1) }
    let(:analysis_2) { FactoryBot.create(:analysis, specimen: specimen_2) }
    let(:analysis_3) { FactoryBot.create(:analysis, specimen: specimen_3) }
    let(:chemistry_1) { FactoryBot.create(:chemistry, analysis: analysis_1, unit: unit, measurement_item: measurement_item, value: 1.0) }
    let(:chemistry_2) { FactoryBot.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 2.0) }
    let(:chemistry_3) { FactoryBot.create(:chemistry, analysis: analysis_3, unit: unit, measurement_item: measurement_item, value: 0.6) }
    before do
      table_specimen_1
      table_specimen_2
    end
    context "row not link chemistry" do
      let(:row) { Table::Row.new(table, category_measurement_item, []) }
      it { expect(subject).to eq nil }
    end
    context "row linked 1 chemistry" do
      let(:row) { Table::Row.new(table, category_measurement_item, [chemistry_1]) }
      it { expect(subject).to eq nil }
    end
    context "row linked chemistries" do
      context "scale is 1" do
        it { expect(subject).to eq 0.7 }
      end
      context "scale is 2" do
        let(:scale) { 2 }
        it { expect(subject).to eq 0.72 }
      end
      context "scale is 3" do
        let(:scale) { 3 }
        it { expect(subject).to eq 0.721 }
      end
    end
  end

  describe "#present?" do
    subject { row.present? }
    let(:row) { Table::Row.new(table, category_measurement_item, [chemistry]) }
    before { allow_any_instance_of(Table::Cell).to receive(:raw).and_return(raw) }
    context "cell.raw return nil" do
      let(:raw) { nil }
      it { expect(subject).to eq false }
    end
    context "cell.raw return 1" do
      let(:raw) { 1 }
      it { expect(subject).to eq true }
    end
  end

  describe "#scale" do
    subject { row.scale }
    let(:row) { Table::Row.new(table, category_measurement_item, [chemistry]) }
    let(:category_measurement_item) { FactoryBot.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item, scale: scale1) }
    let(:measurement_category) { FactoryBot.create(:measurement_category, unit: unit, scale: scale2) }
    let(:measurement_item) { FactoryBot.create(:measurement_item, unit: unit, scale: scale3) }
    let(:scale1) { 1 }
    let(:scale1) { nil }
    let(:scale2) { nil }
    let(:scale3) { nil }
    context "scaleが設定されていない" do
      it { expect(subject).to eq(Table::Row::DEFAULT_SCALE) }
    end
    context "measurement_itemのscaleが設定されている" do
      let(:scale3) { 3 }
      it { expect(subject).to eq scale3 }
      context "measurement_categoryのscaleが設定されている" do
        let(:scale2) { 2 }
        it { expect(subject).to eq scale2 }
        context "category_measurement_itemのscaleが設定されている" do
          let(:scale1) { 1 }
          it { expect(subject).to eq scale1 }
        end
      end
    end
    context "category_measurement_itemのscaleが設定されている" do
      let(:scale1) { 1 }
      it { expect(subject).to eq scale1 }
      context "measurement_categoryのscaleが設定されている" do
        let(:scale2) { 2 }
        it { expect(subject).to eq scale1 }
      end
    end
    context "category_measurement_itemのscaleが設定されている" do
      let(:scale1) { 1 }
      context "measurement_itemのscaleが設定されている" do
        let(:scale3) { 3 }
        it { expect(subject).to eq scale1 }
      end
    end
    context "measurement_categoryのscaleが設定されている" do
      let(:scale2) { 2 }
      it { expect(subject).to eq scale2 }
    end
  end

  describe "#unit" do
    subject { row.unit }
    let(:row) { Table::Row.new(table, category_measurement_item, [chemistry]) }
    let(:category_measurement_item) { FactoryBot.create(:category_measurement_item, measurement_category: measurement_category, unit: unit1, measurement_item: measurement_item) }
    let(:measurement_category) { FactoryBot.create(:measurement_category, unit: unit2) }
    let(:measurement_item) { FactoryBot.create(:measurement_item, unit: unit3) }
    let(:unit1) { nil }
    let(:unit2) { nil }
    let(:unit3) { nil }
    context "unitが設定されていない" do
      it { expect(subject).to eq unit }
    end
    context "measurement_itemにunitが設定されている" do
      let(:unit3) { FactoryBot.create(:unit, name: "unit_name3", conversion: 1, html: "html3", text: "text3") }
      it { expect(subject).to eq unit3 }
      context "measurement_categoryにunitが設定されている" do
        let(:unit2) { FactoryBot.create(:unit, name: "unit_name2", conversion: 1, html: "html2", text: "text2") }
        it { expect(subject).to eq unit2 }
        context "category_measurement_itemにunitが設定されている" do
          let(:unit1) { FactoryBot.create(:unit, name: "unit_name1", conversion: 1, html: "html1", text: "text1") }
          it { expect(subject).to eq unit1 }
        end
      end
    end
    context "category_measurement_itemにunitが設定されている" do
      let(:unit1) { FactoryBot.create(:unit, name: "unit_name1", conversion: 1, html: "html1", text: "text1") }
      it { expect(subject).to eq unit1 }
      context "measurement_categoryにunitが設定されている" do
        let(:unit2) { FactoryBot.create(:unit, name: "unit_name2", conversion: 1, html: "html2", text: "text2") }
        it { expect(subject).to eq unit1 }
      end
    end
    context "category_measurement_itemにunitが設定されている" do
      let(:unit1) { FactoryBot.create(:unit, name: "unit_name1", conversion: 1, html: "html1", text: "text1") }
      context "measurement_itemにunitが設定されている" do
        let(:unit3) { FactoryBot.create(:unit, name: "unit_name3", conversion: 1, html: "html3", text: "text3") }
        it { expect(subject).to eq unit1 }
      end
    end
    context "measurement_categoryにunitが設定されている" do
      let(:unit2) { FactoryBot.create(:unit, name: "unit_name2", conversion: 1, html: "html2", text: "text2") }
      it { expect(subject).to eq unit2 }
    end
  end
end

describe "Table::Cell" do
  let(:cell) { Table::Cell.new(row, table.chemistries) }
  let(:row) { Table::Row.new(table, category_measurement_item, table.chemistries) }
  let(:table) { FactoryBot.create(:table, measurement_category: measurement_category) }
  let(:measurement_category) { FactoryBot.create(:measurement_category, unit: unit) }
  let(:unit) { FactoryBot.create(:unit, name: "gram_per_gram", conversion: 1) }
  let(:category_measurement_item) { FactoryBot.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
  let(:measurement_item) { FactoryBot.create(:measurement_item, unit: unit) }
  let(:table_specimen) { FactoryBot.create(:table_specimen, table: table, specimen: specimen) }
  let(:specimen) { FactoryBot.create(:specimen) }
  let(:analysis) { FactoryBot.create(:analysis, specimen: specimen) }
  let(:chemistry) { FactoryBot.create(:chemistry, analysis: analysis, unit: unit, measurement_item: measurement_item, value: 1) }
  let(:analysis_2) { FactoryBot.create(:analysis, specimen: specimen) }
  let(:chemistry_2) { FactoryBot.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 1) }

  before do
    Alchemist.setup
    Alchemist.register(:mass, unit.name.to_sym, 1.to_d / unit.conversion)
  end

  describe "#raw" do
    subject { cell.raw }
    before { allow_any_instance_of(Alchemist).to receive(:value).and_return(value) }
    let(:value) { 1.0 }
    context "table have not link chemistry" do
      it { expect(subject).to be_nil }
    end
    context "table linked chemistry" do
      before do
        specimen
        analysis
        table
        table_specimen
        chemistry
      end
      it { expect(subject).to eq value }
    end

    context "table linked 2 chemistry" do
      before do
        specimen
        analysis
        table
        table_specimen
        chemistry
        chemistry_2
      end
      it { expect(subject).to eq value }
    end

  end

  describe "value" do
    subject { cell.value }
    context "table have not link chemistry" do
      it { expect(subject).to be_nil }
    end
    context "table linked chemistry" do
      before do
        specimen
        analysis
        table
        table_specimen
        chemistry
        allow(cell).to receive(:raw).and_return(1)
      end
      it { expect(subject).to eq(1.round(row.scale)) }
    end
  end

  describe "symbol" do
    subject { cell.symbol }
    context "table have not link chemistry" do
      it { expect(subject).to be_nil }
    end
    context "table linked chemistry" do
      before do
        specimen
        analysis
        table
        table_specimen
        chemistry
        allow(table).to receive(:method_sign).with(analysis.technique, analysis.device).and_return(:method_sign)
      end
      it { expect(subject).to eq(:method_sign) }
    end
  end

  describe "#present?" do
    subject { cell.present? }
    context "table have not link chemistry" do
      it { expect(subject).to eq false }
    end
    context "table linked chemistry" do
      before do
        specimen
        analysis
        table
        table_specimen
        chemistry
      end
      it { expect(subject).to eq true }
    end
  end

  describe "pml_elements" do
    subject { obj.pml_elements }
    let(:obj) { FactoryBot.create(:table)}
    let(:analysis_1) { FactoryBot.create(:analysis) }
    let(:analysis_2) { FactoryBot.create(:analysis, name: "分類2") }
    let(:analysis_3) { FactoryBot.create(:analysis, name: "分類3") }
    let(:analysis_4) { FactoryBot.create(:analysis, name: "分類4") }
    before do
      obj.analyses << analysis_1
      obj.analyses << analysis_2
      allow(obj).to receive(:selected_analyses).and_return([analysis_3, analysis_3, analysis_4])
    end
    it { expect(subject).to match_array([analysis_3, analysis_4]) }
  end
end
