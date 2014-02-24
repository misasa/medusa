require 'spec_helper'

describe RecordsHelper do

  describe "#contain_searchable_symbol" do
    subject { helper.contain_searchable_symbol(attribute) }
    let(:attribute) { "attribute" }
    let(:matcher) { "matcher" }
    before { allow(helper).to receive(:ransackable_matcher).with(attribute).and_return(matcher) }
    it { expect(subject).to eq :matcher_cont }
  end

  describe "#gteq_searchable_symbol" do
    subject { helper.gteq_searchable_symbol(attribute) }
    let(:attribute) { "attribute" }
    let(:matcher) { "matcher" }
    before { allow(helper).to receive(:ransackable_matcher).with(attribute).and_return(matcher) }
    it { expect(subject).to eq :matcher_gteq }
  end

  describe "#lteq_searchable_symbol" do
    subject { helper.lteq_searchable_symbol(attribute) }
    let(:attribute) { "attribute" }
    let(:matcher) { "matcher" }
    before { allow(helper).to receive(:ransackable_matcher).with(attribute).and_return(matcher) }
    it { expect(subject).to eq :matcher_lteq_end_of_day }
  end

  describe "#ransackable_matcher" do
    subject { helper.send(:ransackable_matcher, attribute) }
    let(:attribute) { "name" }
    it { expect(subject).to eq "datum_of_Stone_type_name_or_datum_of_Box_type_name_or_datum_of_Place_type_name_or_datum_of_Analysis_type_name_or_datum_of_Bib_type_name_or_datum_of_AttachmentFile_type_name" }
  end

end
