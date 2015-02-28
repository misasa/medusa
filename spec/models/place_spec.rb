require "spec_helper"

describe Place do

  describe "constants" do
    describe "TEMPLATE_HEADER" do
      subject { Place::TEMPLATE_HEADER }
      it { expect(subject).to eq "name,latitude(decimal degree),longitude(decimal degree),elevation(m),description\n" }
    end
    describe "PERMIT_IMPORT_TYPES" do
      subject { Place::PERMIT_IMPORT_TYPES }
      it { expect(subject).to include("text/plain", "text/csv", "application/csv", "application/vnd.ms-excel") }
    end
  end

  describe "#analyses" do
    let(:obj){FactoryGirl.create(:place) }
    let(:stone_1) { FactoryGirl.create(:stone, name: "hoge", place_id: obj.id) }
    let(:stone_2) { FactoryGirl.create(:stone, name: "stone_2", place_id: obj.id) }
    let(:stone_3) { FactoryGirl.create(:stone, name: "stone_3", place_id: obj.id) }
    let(:analysis_1) { FactoryGirl.create(:analysis, stone_id: stone_1.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, stone_id: stone_2.id) }
    let(:analysis_3) { FactoryGirl.create(:analysis, stone_id: stone_3.id) }
    before do
      stone_1;stone_2;stone_3;      
      analysis_1;analysis_2;analysis_3;
    end
    it { expect(obj.analyses).to match_array([analysis_1,analysis_2,analysis_3])}    
  end

  describe ".import_csv" do
    subject { Place.import_csv(file) }
    context "file is nil" do
      let(:file) { nil }
      it { expect(subject).to be_nil }
    end
    context "file is present" do
      let(:file) { double(:file) }
      before do
        allow(file).to receive(:content_type).and_return(content_type)
        allow(file).to receive(:read).and_return("name,latitude,longitude,elevation,description\nplace,1,2,3,")
      end
      context "content_type is 'image/png'" do
        let(:content_type) { 'image/png' }
        it { expect(subject).to be_nil }
      end
      context "content_type is 'text/csv'" do
        let(:content_type) { 'text/csv' }
        it { expect(subject).to be_present }
      end
      context "content_type is 'text/plain'" do
        let(:content_type) { 'text/plain' }
        it { expect(subject).to be_present }
      end
      context "content_type is 'application/csv'" do
        let(:content_type) { 'application/csv' }
        it { expect(subject).to be_present }
      end
    end
  end

 describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:place, name: name) }
      context "is presence" do
        let(:name) { "sample_obj_name" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:name) { "" }
        it { expect(obj).not_to be_valid }
      end
      describe "length" do
        context "is 255 characters" do
          let(:name) { "a" * 255 }
          it { expect(obj).to be_valid }
        end
        context "is 256 characters" do
          let(:name) { "a" * 256 }
          it { expect(obj).not_to be_valid }
        end
      end
    end
  end
end
