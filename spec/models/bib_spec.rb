require "spec_helper"

describe Bib do
  
  describe ".doi_link_url" do
    subject { bib.doi_link_url }
    let(:bib) { FactoryGirl.create(:bib, doi: doi_1) }
    context "doi is nil" do
      let(:doi_1) { nil }
      it { expect(subject).to be_nil }
    end
    context "doi is not nil" do
      let(:doi_1) { "test" }
      it { expect(subject).to eq "http://dx.doi.org/test" }
    end
  end
  
end
