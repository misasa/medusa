require 'spec_helper'

describe RecordsHelper do

  describe "#contain_searchable_symbol" do
    subject { helper.contain_searchable_symbol(attribute) }
    let(:attribute) { "attribute" }
    let(:matcher) { "matcher" }
    before { allow(helper).to receive(:records_search_matcher).with(attribute).and_return(matcher) }
    it { expect(subject).to eq :matcher_cont }
  end

  describe "#gteq_searchable_symbol" do
    subject { helper.gteq_searchable_symbol(attribute) }
    let(:attribute) { "attribute" }
    let(:matcher) { "matcher" }
    before { allow(helper).to receive(:records_search_matcher).with(attribute).and_return(matcher) }
    it { expect(subject).to eq :matcher_gteq }
  end

  describe "#lteq_searchable_symbol" do
    subject { helper.lteq_searchable_symbol(attribute) }
    let(:attribute) { "attribute" }
    let(:matcher) { "matcher" }
    before { allow(helper).to receive(:records_search_matcher).with(attribute).and_return(matcher) }
    it { expect(subject).to eq :matcher_lteq_end_of_day }
  end

end
