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
    let(:specimen_1) { FactoryGirl.create(:specimen, name: "hoge", place_id: obj.id) }
    let(:specimen_2) { FactoryGirl.create(:specimen, name: "specimen_2", place_id: obj.id) }
    let(:specimen_3) { FactoryGirl.create(:specimen, name: "specimen_3", place_id: obj.id) }
    let(:analysis_1) { FactoryGirl.create(:analysis, specimen_id: specimen_1.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, specimen_id: specimen_2.id) }
    let(:analysis_3) { FactoryGirl.create(:analysis, specimen_id: specimen_3.id) }
    before do
      specimen_1;specimen_2;specimen_3;      
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

  describe ".to_dms", :current => true do
    subject {Place.to_dms(degree) }
    let(:degree){ 5.625 }
    it { expect(subject[:deg]).to be_eql(5) }
    it { expect(subject[:min]).to be_eql(37) }
    it { expect(subject[:sec]).to be_eql(30.0) }
  end

  describe ".from_dms", :current => true do
    subject {Place.from_dms(deg, min, sec) }
    let(:dms){ {deg: 5, min: min, sec: sec} }
    let(:deg){ 5 }
    let(:min){ 37 }
    let(:sec){ 30.0 }
    context "with sec" do 
      it { expect(format("%.3f", subject)).to be_eql("5.625") }
    end

    context "without sec" do 
      let(:sec){ nil }
      it { expect(format("%.3f", subject)).to be_eql("5.617") }
    end

  end


  describe "before_save", :current => true do
    subject { obj.save }
    let(:obj){ FactoryGirl.build(:place, attributes)}
    let(:attributes){ {name: "test", latitude: nil, longitude: nil, latitude_direction: latitude_direction, latitude_deg: deg, latitude_min: min, latitude_sec: sec, longitude_direction: longitude_direction, longitude_deg: deg, longitude_min: min, longitude_sec: sec} }
    let(:latitude_direction){ "N" }
    let(:longitude_direction){ "S" }
    let(:deg){ "5" }
    let(:min){ "37" }
    let(:sec){ "30.0" }
    before do
      subject
    end
    it { expect(obj.latitude).not_to be_nil }
    it { expect(obj.longitude).not_to be_nil }

  end

  describe "latitude_in_text", :current => true do
    subject { obj.latitude_in_text }
    let(:obj){ FactoryGirl.create(:place, name: "test", latitude: degree, longitude: 5.625) }
    context "degree > 0" do
      let(:degree) { 5.625 }
      it { expect(subject).to be_eql("N 5 deg. 37 min. 30.0 sec.") }
    end

    context "degree < 0" do
      let(:degree) { -5.625 }
      it { expect(subject).to be_eql("S 5 deg. 37 min. 30.0 sec.") }
    end

  end

  describe "longitude_in_text", :current => true do
    subject { obj.longitude_in_text }
    let(:obj){ FactoryGirl.create(:place, name: "test", latitude: degree, longitude: degree) }
    context "degree > 0" do
      let(:degree) { 5.625 }
      it { expect(subject).to be_eql("E 5 deg. 37 min. 30.0 sec.") }
    end

    context "degree < 0" do
      let(:degree) { -5.625 }
      it { expect(subject).to be_eql("W 5 deg. 37 min. 30.0 sec.") }
    end

  end

end
 