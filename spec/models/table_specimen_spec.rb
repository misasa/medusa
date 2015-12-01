require "spec_helper"

describe "TableSpecimen" do

  describe "before_create" do
    describe "assign_position" do
      let(:table_specimen) { FactoryGirl.create(:table_specimen, position: nil, table: table) }
      let(:table) { FactoryGirl.create(:table) }
      subject { table_specimen.position }
      context "not exists other table_specimen record" do
        before do
          table_specimen
          table_specimen.reload
        end
        it { expect(subject).to eq 1 }
      end
      context "exists other table_specimen record" do
        let(:other_table_specimen_1) { FactoryGirl.create(:table_specimen, position: 10, table: table) }
        let(:other_table_specimen_2) { FactoryGirl.create(:table_specimen, position: 20, table: table_2) }
        let(:table_2) { FactoryGirl.create(:table) }
        before do
          other_table_specimen_1
          other_table_specimen_2
          table_specimen
          table_specimen.reload
        end
        it { expect(subject).to eq(other_table_specimen_1.position + 1) }
      end
    end
    
    describe "create_table_analyses" do
      let(:table_specimen) { FactoryGirl.create(:table_specimen, specimen: specimen, table: table) }
      let(:specimen) { FactoryGirl.create(:specimen) }
      let(:table) { FactoryGirl.create(:table) }
      let(:analysis_1) { FactoryGirl.create(:analysis, specimen: specimen) }
      let(:analysis_2) { FactoryGirl.create(:analysis, specimen: specimen) }
      before do
        analysis_1
        analysis_2
      end
      it { expect { table_specimen }.to change(TableAnalysis, :count).from(0).to(2) }
      describe "TableAnalysis record" do
        before { table_specimen }
        it { expect(TableAnalysis.pluck(:table_id)).to eq [table.id, table.id] }
        it { expect(TableAnalysis.pluck(:specimen_id)).to eq [specimen.id, specimen.id] }
        it { expect(TableAnalysis.pluck(:analysis_id)).to include(analysis_1.id, analysis_2.id) }
        it { expect(TableAnalysis.pluck(:priority)).to include(0, 1) }
      end
    end
  end

end

