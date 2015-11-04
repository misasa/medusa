require "spec_helper"

describe "TableStone" do

  describe "before_create" do
    describe "assign_position" do
      let(:table_stone) { FactoryGirl.create(:table_stone, position: nil, table: table) }
      let(:table) { FactoryGirl.create(:table) }
      subject { table_stone.position }
      context "not exists other table_stone record" do
        before do
          table_stone
          table_stone.reload
        end
        it { expect(subject).to eq 1 }
      end
      context "exists other table_stone record" do
        let(:other_table_stone_1) { FactoryGirl.create(:table_stone, position: 10, table: table) }
        let(:other_table_stone_2) { FactoryGirl.create(:table_stone, position: 20, table: table_2) }
        let(:table_2) { FactoryGirl.create(:table) }
        before do
          other_table_stone_1
          other_table_stone_2
          table_stone
          table_stone.reload
        end
        it { expect(subject).to eq(other_table_stone_1.position + 1) }
      end
    end
    
    describe "create_table_analyses" do
      let(:table_stone) { FactoryGirl.create(:table_stone, stone: stone, table: table) }
      let(:stone) { FactoryGirl.create(:stone) }
      let(:table) { FactoryGirl.create(:table) }
      let(:analysis_1) { FactoryGirl.create(:analysis, stone: stone) }
      let(:analysis_2) { FactoryGirl.create(:analysis, stone: stone) }
      before do
        analysis_1
        analysis_2
      end
      it { expect { table_stone }.to change(TableAnalysis, :count).from(0).to(2) }
      describe "TableAnalysis record" do
        before { table_stone }
        it { expect(TableAnalysis.pluck(:table_id)).to eq [table.id, table.id] }
        it { expect(TableAnalysis.pluck(:stone_id)).to eq [stone.id, stone.id] }
        it { expect(TableAnalysis.pluck(:analysis_id)).to include(analysis_1.id, analysis_2.id) }
        it { expect(TableAnalysis.pluck(:priority)).to include(0, 1) }
      end
    end
  end

end

