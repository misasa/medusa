require "spec_helper"

describe "Table" do
  let(:table) { FactoryGirl.create(:table, measurement_category: measurement_category) }
  let(:measurement_category) { FactoryGirl.create(:measurement_category, unit: unit) }
  let(:unit) { FactoryGirl.create(:unit) }
  let(:category_measurement_item) { FactoryGirl.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
  let(:measurement_item) { FactoryGirl.create(:measurement_item, unit: unit) }
  let(:table_stone) { FactoryGirl.create(:table_stone, table: table, stone: stone) }
  let(:stone) { FactoryGirl.create(:stone) }
  let(:analysis) { FactoryGirl.create(:analysis, stone: stone) }
  let(:chemistry) { FactoryGirl.create(:chemistry, analysis: analysis, unit: unit, measurement_item: measurement_item) }
  
  describe "validates" do
    describe "age_unit" do
      subject { table.valid? }
      let(:table) { FactoryGirl.build(:table, with_age: with_age, age_unit: age_unit) }
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
  end
  
  describe "#each" do
    context "table not link category_measurement_item" do
      it { expect { |b| table.each(&b) }.not_to yield_control }
    end
    context "table linked 1 category_measurement_item" do
      before do
        category_measurement_item_1
        table_stone
        analysis
        chemistry
        allow(Table::Row).to receive(:new).with(table, category_measurement_item_1, [chemistry]).and_return(:row_1)
      end
      let(:category_measurement_item_1) { FactoryGirl.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
      it { expect { |b| table.each(&b) }.to yield_control.once }
      it { expect { |b| table.each(&b) }.to yield_successive_args(:row_1) }
    end
    context "table linked 2 category_measurement_items" do
      before do
        category_measurement_item_1
        category_measurement_item_2
        table_stone
        analysis
        chemistry
        allow(Table::Row).to receive(:new).with(table, category_measurement_item_1, [chemistry]).and_return(:row_1)
        allow(Table::Row).to receive(:new).with(table, category_measurement_item_2, [chemistry]).and_return(:row_2)
      end
      let(:category_measurement_item_1) { FactoryGirl.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
      let(:category_measurement_item_2) { FactoryGirl.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
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
      let(:technique_1) { FactoryGirl.create(:technique, name: "technique_1") }
      let(:device_1) { FactoryGirl.create(:device, name: "device_1") }
      it { expect(subject).to eq({"a" => "#{technique_1.name} on #{device_1.name}"}) }
    end
    context "table has 2 descriptions" do
      before do
        table.method_sign(technique_1, device_1)
        table.method_sign(technique_2, device_2)
      end
      let(:technique_1) { FactoryGirl.create(:technique, name: "technique_1") }
      let(:technique_2) { FactoryGirl.create(:technique, name: "technique_2") }
      let(:device_1) { FactoryGirl.create(:device, name: "device_1") }
      let(:device_2) { FactoryGirl.create(:device, name: "device_2") }
      it { expect(subject).to eq({"a" => "#{technique_1.name} on #{device_1.name}", "b" => "#{technique_2.name} on #{device_2.name}"}) }
    end
  end
  
  describe "#method_sign" do
    context "method call once" do
      subject { table.method_sign(technique, device) }
      let(:technique) { FactoryGirl.create(:technique) }
      let(:device) { FactoryGirl.create(:device) }
      context "technique is nil" do
        let(:technique) { nil }
        context "device is nil" do
          let(:device) { nil }
          it { expect(subject).to be_nil }
        end
        context "device is present" do
          it { expect(subject).to eq "a" }
          it { subject; expect(table.send(:methods_hash)).to eq({ [nil, device.id] => {:sign => "a", :description => "on #{device.name}"} }) }
        end
      end
      context "technique is present" do
        context "device is nil" do
          let(:device) { nil }
          it { expect(subject).to eq "a" }
          it { subject; expect(table.send(:methods_hash)).to eq({ [technique.id, nil] => {:sign => "a", :description => "#{technique.name} "} }) }
        end
        context "device is present" do
          it { expect(subject).to eq "a" }
          it { subject; expect(table.send(:methods_hash)).to eq({ [technique.id, device.id] => {:sign => "a", :description => "#{technique.name} on #{device.name}"} }) }
        end
      end
    end
    context "method call twice" do
      before { table.method_sign(technique_1, device_1) }
      subject { table.method_sign(technique_2, device_2) }
      let(:technique_1) { FactoryGirl.create(:technique, name: "technique_1") }
      let(:technique_2) { FactoryGirl.create(:technique, name: "technique_2") }
      let(:device_1) { FactoryGirl.create(:device, name: "device_1") }
      let(:device_2) { FactoryGirl.create(:device, name: "device_2") }
      it { expect(subject).to eq "b" }
      it do
        subject
        expect(table.send(:methods_hash)).to eq({
          [technique_1.id, device_1.id] => {:sign => "a", :description => "#{technique_1.name} on #{device_1.name}"},
          [technique_2.id, device_2.id] => {:sign => "b", :description => "#{technique_2.name} on #{device_2.name}"}
        })
      end
    end
  end
  
  describe "#priority" do
    subject { table.priority(analysis_id) }
    let(:analysis_id) { analysis_2.id }
    let(:analysis_1) { FactoryGirl.create(:analysis, stone: stone) }
    let(:analysis_2) { FactoryGirl.create(:analysis, stone: stone) }
    let(:table_analysis_1) { FactoryGirl.create(:table_analysis, table: table, stone: stone, analysis: analysis_1, priority: 1) }
    let(:table_analysis_2) { FactoryGirl.create(:table_analysis, table: table, stone: stone, analysis: analysis_2, priority: 2) }
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

describe "Table::Row" do
  let(:row) { Table::Row.new(table, category_measurement_item, [chemistry]) }
  let(:table) { FactoryGirl.create(:table, measurement_category: measurement_category) }
  let(:measurement_category) { FactoryGirl.create(:measurement_category, unit: unit) }
  let(:unit) { FactoryGirl.create(:unit, name: "gram_per_gram", conversion: 1) }
  let(:category_measurement_item) { FactoryGirl.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
  let(:measurement_item) { FactoryGirl.create(:measurement_item, unit: unit, nickname: "測定１", display_in_html: "[A]", display_in_tex: "\abundance{A}") }
  let(:stone) { FactoryGirl.create(:stone) }
  let(:analysis) { FactoryGirl.create(:analysis, stone: stone) }
  let(:chemistry) { FactoryGirl.create(:chemistry, analysis: analysis, unit: unit, measurement_item: measurement_item) }
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
  
  describe "#each" do
    context "table not link table_stone" do
      it { expect { |b| table.each(&b) }.not_to yield_control }
    end
    context "table linked 1 table_stone" do
      before do
        table_stone_1
        allow(Table::Cell).to receive(:new).with(row, [chemistry]).and_return(:cell)
      end
      let(:table_stone_1) { FactoryGirl.create(:table_stone, table: table, stone: stone) }
      it { expect { |b| row.each(&b) }.to yield_control.once }
      it { expect { |b| row.each(&b) }.to yield_successive_args(:cell) }
    end
    context "table linked 2 table_stones" do
      before do
        table_stone_1
        table_stone_2
        allow(Table::Cell).to receive(:new).with(row, [chemistry]).and_return(:cell)
      end
      let(:table_stone_1) { FactoryGirl.create(:table_stone, table: table, stone: stone) }
      let(:table_stone_2) { FactoryGirl.create(:table_stone, table: table, stone: stone) }
      it { expect { |b| row.each(&b) }.to yield_control.twice }
      it { expect { |b| row.each(&b) }.to yield_successive_args(:cell, :cell) }
    end
  end
  
  describe "#mean" do
    subject { row.mean(round_flag) }
    let(:round_flag) { false }
    let(:category_measurement_item) { FactoryGirl.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item, scale: scale) }
    let(:scale) { 1 }
    context "round_flag is false" do
      context "table linked 1 chemistry" do
        it { expect(subject).to eq(chemistry.value) }
      end
      context "table linked 2 chemistries" do
        let(:row) { Table::Row.new(table, category_measurement_item, [chemistry_1, chemistry_2]) }
        let(:table_stone_1) { FactoryGirl.create(:table_stone, table: table, stone: stone_1) }
        let(:table_stone_2) { FactoryGirl.create(:table_stone, table: table, stone: stone_2) }
        let(:stone_1) { FactoryGirl.create(:stone) }
        let(:stone_2) { FactoryGirl.create(:stone) }
        let(:analysis_1) { FactoryGirl.create(:analysis, stone: stone_1) }
        let(:analysis_2) { FactoryGirl.create(:analysis, stone: stone_2) }
        let(:chemistry_1) { FactoryGirl.create(:chemistry, analysis: analysis_1, unit: unit, measurement_item: measurement_item, value: 1) }
        let(:chemistry_2) { FactoryGirl.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 2) }
        before do
          table_stone_1
          table_stone_2
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
          let(:table_stone_1) { FactoryGirl.create(:table_stone, table: table, stone: stone_1) }
          let(:table_stone_2) { FactoryGirl.create(:table_stone, table: table, stone: stone_2) }
          let(:stone_1) { FactoryGirl.create(:stone) }
          let(:stone_2) { FactoryGirl.create(:stone) }
          let(:analysis_1) { FactoryGirl.create(:analysis, stone: stone_1) }
          let(:analysis_2) { FactoryGirl.create(:analysis, stone: stone_2) }
          let(:chemistry_1) { FactoryGirl.create(:chemistry, analysis: analysis_1, unit: unit, measurement_item: measurement_item, value: 1) }
          let(:chemistry_2) { FactoryGirl.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 2) }
          before do
            table_stone_1
            table_stone_2
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
    let(:category_measurement_item) { FactoryGirl.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item, scale: scale) }
    let(:scale) { 1 }
    let(:table_stone_1) { FactoryGirl.create(:table_stone, table: table, stone: stone_1) }
    let(:table_stone_2) { FactoryGirl.create(:table_stone, table: table, stone: stone_2) }
    let(:table_stone_3) { FactoryGirl.create(:table_stone, table: table, stone: stone_3) }
    let(:stone_1) { FactoryGirl.create(:stone) }
    let(:stone_2) { FactoryGirl.create(:stone) }
    let(:stone_3) { FactoryGirl.create(:stone) }
    let(:analysis_1) { FactoryGirl.create(:analysis, stone: stone_1) }
    let(:analysis_2) { FactoryGirl.create(:analysis, stone: stone_2) }
    let(:analysis_3) { FactoryGirl.create(:analysis, stone: stone_3) }
    let(:chemistry_1) { FactoryGirl.create(:chemistry, analysis: analysis_1, unit: unit, measurement_item: measurement_item, value: 1.0) }
    let(:chemistry_2) { FactoryGirl.create(:chemistry, analysis: analysis_2, unit: unit, measurement_item: measurement_item, value: 2.0) }
    let(:chemistry_3) { FactoryGirl.create(:chemistry, analysis: analysis_3, unit: unit, measurement_item: measurement_item, value: 0.6) }
    before do
      table_stone_1
      table_stone_2
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
    let(:category_measurement_item) { FactoryGirl.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item, scale: scale) }
    let(:scale) { 1 }
    context "scale is 1" do
      it { expect(subject).to eq scale }
    end
    context "scale is 0" do
      let(:scale) { 0 }
      it { expect(subject).to eq scale }
    end
    context "scale is nil" do
      let(:scale) { nil }
      it { expect(subject).to eq(Table::Row::DEFAULT_SCALE) }
    end
  end
  
end

describe "Table::Cell" do
  let(:cell) { Table::Cell.new(row, table.chemistries) }
  let(:row) { Table::Row.new(table, category_measurement_item, table.chemistries) }
  let(:table) { FactoryGirl.create(:table, measurement_category: measurement_category) }
  let(:measurement_category) { FactoryGirl.create(:measurement_category, unit: unit) }
  let(:unit) { FactoryGirl.create(:unit, name: "gram_per_gram", conversion: 1) }
  let(:category_measurement_item) { FactoryGirl.create(:category_measurement_item, measurement_category: measurement_category, unit: unit, measurement_item: measurement_item) }
  let(:measurement_item) { FactoryGirl.create(:measurement_item, unit: unit) }
  let(:table_stone) { FactoryGirl.create(:table_stone, table: table, stone: stone) }
  let(:stone) { FactoryGirl.create(:stone) }
  let(:analysis) { FactoryGirl.create(:analysis, stone: stone) }
  let(:chemistry) { FactoryGirl.create(:chemistry, analysis: analysis, unit: unit, measurement_item: measurement_item, value: 1) }
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
        table_stone
        chemistry
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
        table_stone
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
        table_stone
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
        table_stone
        chemistry
      end
      it { expect(subject).to eq true }
    end
  end
  
end

