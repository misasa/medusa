require "spec_helper"

describe Place do

  describe "constants" do
    describe "TEMPLATE_HEADER" do
      subject { Place::TEMPLATE_HEADER }
      it { expect(subject).to eq "name,latitude(decimal degree),longitude(decimal degree),elevation(m),description\n" }
    end
  end

  describe ".import_csv" do
    subject { Place.import_csv(file) }
    let(:file) { double(:file) }
    before do
      allow(file).to receive(:content_type).and_return(content_type)
      allow(file).to receive(:read).and_return("name,latitude,longitude,elevation,description\nplace,1,2,3,")
    end
    context "content_type is 'image/png'" do
      let(:content_type) { 'image/png' }
      it { expect(subject).to be_nil }
    end
    context "content_type is 'text'" do
      let(:content_type) { 'text' }
      it { expect(subject).to be_nil }
    end
    context "content_type is 'text/csv'" do
      let(:content_type) { 'text/csv' }
      it { expect(subject).to be_present }
    end
  end

end
