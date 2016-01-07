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

  describe ".accessor_dms" do
    let(:place){ FactoryGirl.create(:place, latitude: latitude, longitude: longitude)}
    let(:latitude){ 5.625 }
    let(:longitude){ 5.625 }
    it {
      expect(place.latitude_dms_direction).to be_eql("N")
      expect(place.latitude_dms_deg).to be_eql(5)
      expect(place.latitude_dms_min).to be_eql(37)
      expect(place.latitude_dms_sec).to be_eql(30.0)
      expect(place.longitude_dms_direction).to be_eql("E")
      expect(place.longitude_dms_deg).to be_eql(5)
      expect(place.longitude_dms_min).to be_eql(37)
      expect(place.longitude_dms_sec).to be_eql(30.0)

    }
  end

  describe ".latitude_dms" do
    subject { place.latitude_dms }
    context "with latitude" do
      let(:place){ FactoryGirl.create(:place, latitude: latitude) }
      context "with positive" do
        let(:latitude){ 5.625 }
        it { expect(subject[:direction]).to be_eql("N") }
        it { expect(subject[:deg]).to be_eql(5) }
        it { expect(subject[:min]).to be_eql(37) }
        it { expect(subject[:sec]).to be_eql(30.0) }      

      end
      context "with negative" do
        let(:latitude){ -5.625 }
        it { expect(subject[:direction]).to be_eql("S") }
        it { expect(subject[:deg]).to be_eql(5) }
        it { expect(subject[:min]).to be_eql(37) }
        it { expect(subject[:sec]).to be_eql(30.0) }
      end
    end
    context "without latitude" do
      let(:place){ FactoryGirl.create(:place, latitude: nil) }
      it { expect(subject[:direction]).to be_nil }
      context "after set latitude_dms_direction=" do
        before do
          place.latitude_dms_direction = "N"
        end
        it { expect(subject[:direction]).to be_eql("N") }
      end
    end
  end


  describe ".longitude_dms" do
    subject { place.longitude_dms }
    context "with longitude" do
      let(:place){ FactoryGirl.create(:place, longitude: longitude) }
      context "with positive" do
        let(:longitude){ 5.625 }
        it { expect(subject[:direction]).to be_eql("E") }
        it { expect(subject[:deg]).to be_eql(5) }
        it { expect(subject[:min]).to be_eql(37) }
        it { expect(subject[:sec]).to be_eql(30.0) }      

      end
      context "with negative" do
        let(:longitude){ -5.625 }
        it { expect(subject[:direction]).to be_eql("W") }
        it { expect(subject[:deg]).to be_eql(5) }
        it { expect(subject[:min]).to be_eql(37) }
        it { expect(subject[:sec]).to be_eql(30.0) }
      end
    end
    context "without longitude" do
      let(:place){ FactoryGirl.create(:place, longitude: nil) }
      it { expect(subject[:direction]).to be_nil }
      context "after set longitude_direction=" do
        before do
          place.longitude_dms_direction = "E"
        end
        it { expect(subject[:direction]).to be_eql("E") }
      end
    end
  end

  describe ".logitude_dms_*" do
    let(:place){ FactoryGirl.create(:place, longitude: longitude) }
    let(:longitude){ 5.317 }
    describe "direction" do
      subject { place.longitude_dms_direction }
      it { expect(subject).to be_eql("E") }
    end

    describe "deg" do
      subject { place.longitude_dms_deg }
      it { expect(subject).to be_eql(5) }
    end

    describe "direction=" do
      subject { place.longitude_dms_direction = direction }
      let(:place){ FactoryGirl.create(:place, longitude: nil) }
      let(:direction){ "E" }
      before do
        subject
      end
      it { expect(place.longitude_dms_direction).to be_eql(direction) }
    end

  end

  describe ".latitude_dms_*" do
    context "with latitude" do
      let(:place){ FactoryGirl.create(:place, latitude: latitude) }
      let(:latitude){ 5.625 }
      it {
        expect(place.latitude_dms_direction).to be_eql("N")      
        expect(place.latitude_dms_deg).to be_eql(5)
        expect(place.latitude_dms_min).to be_eql(37)
        expect(place.latitude_dms_sec).to be_eql(30.0)      
      }
      context "with minus latitude" do
        let(:latitude){ -5.625 }
        it {
          expect(place.latitude_dms_direction).to be_eql("S")      
          expect(place.latitude_dms_deg).to be_eql(5)
          expect(place.latitude_dms_min).to be_eql(37)
          expect(place.latitude_dms_sec).to be_eql(30.0)      
        }
      end
    end

    context "with latitude_dms_*=" do
      let(:place){ FactoryGirl.create(:place, latitude_dms_direction: latitude_direction, latitude_dms_deg: latitude_deg, latitude_dms_min: latitude_min, latitude_dms_sec: latitude_sec) }
      let(:latitude){ 5.625 }
      let(:latitude_direction){ "N" }
      let(:latitude_deg){ 5 }
      let(:latitude_min){ 37 }
      let(:latitude_sec){ 30.0 }

      it {
        expect(place.latitude_dms_direction).to be_eql("N")      
        expect(place.latitude_dms_deg).to be_eql(5)
        expect(place.latitude_dms_min).to be_eql(37)
        expect(place.latitude_dms_sec).to be_eql(30.0)      
      }
    end

  end

  describe ".latitude_dms_deg=" do
    subject { place.latitude_dms_deg = latitude_deg }
    let(:place){ FactoryGirl.build(:place, latitude: nil) }
    let(:latitude_deg){ 35 }
    before do
      subject
    end
    it {
      expect(place.latitude_dms_deg).to be_eql(latitude_deg)
    }
    context "after save" do
      before do
        subject
        place.save
      end
      it {
        expect(place.latitude).not_to be_nil
      }
    end
  end

  describe ".to_dms" do
    subject {Place.to_dms(degree) }
    let(:degree){ 5.625 }
    it { expect(subject[:deg]).to be_eql(5) }
    it { expect(subject[:min]).to be_eql(37) }
    it { expect(subject[:sec]).to be_eql(30.0) }
  end

  describe ".from_dms" do
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
    context "create" do
      let(:obj){ FactoryGirl.build(:place, attributes)}
      let(:attributes){ {name: "test", latitude: nil, longitude: nil, latitude_dms_direction: latitude_dms_direction, latitude_dms_deg: deg, latitude_dms_min: min, latitude_dms_sec: sec, longitude_dms_direction: longitude_dms_direction, longitude_dms_deg: deg, longitude_dms_min: min, longitude_dms_sec: sec} }
      let(:latitude_dms_direction){ "N" }
      let(:longitude_dms_direction){ "S" }
      let(:deg){ "5" }
      let(:min){ "37" }
      let(:sec){ "30.0" }
      before do
        subject
      end
      it { expect(obj.latitude).not_to be_nil }
      it { expect(obj.longitude).not_to be_nil }
    end

    context "update" do
      subject { obj.update_attributes(attributes) }
      let(:obj){ FactoryGirl.create(:place, attributes)}
      let(:attributes){ {name: "test", latitude_dms_direction: latitude_dms_direction, latitude_dms_deg: deg, latitude_dms_min: min, latitude_dms_sec: sec, longitude_dms_direction: longitude_dms_direction, longitude_dms_deg: deg, longitude_dms_min: min, longitude_dms_sec: sec} }
      let(:latitude_dms_direction){ "N" }
      let(:longitude_dms_direction){ "S" }
      let(:deg){ "5" }
      let(:min){ "37" }
      let(:sec){ "30.0" }
      before do
        subject
      end
      it { expect(obj.latitude.round(3)).to be_eql(5.625) }      
      it { expect(obj.longitude.round(3)).to be_eql(5.625) }
      context "without _dms_deg" do
        let(:attributes){ {name: "test", latitude_dms_direction: latitude_dms_direction } }
        let(:latitude_dms_direction){ "N" }
        before do
          subject
        end
        it { expect(obj.latitude).to be_eql(1.0) }
      end
    end

  end

  describe "latitude_in_text" do
    subject { obj.latitude_in_text }
    let(:obj){ FactoryGirl.create(:place, name: "test", latitude: degree, longitude: nil) }
    context "degree > 0" do
      let(:degree) { 5.625 }
      it { expect(subject).to be_eql("N 5 degree 37 minute 30.0 second") }
    end

    context "degree < 0" do
      let(:degree) { -5.625 }
      it { expect(subject).to be_eql("S 5 degree 37 minute 30.0 second") }
    end

  end

  describe "longitude_in_text" do
    subject { obj.longitude_in_text }
    let(:obj){ FactoryGirl.create(:place, name: "test", latitude: nil, longitude: degree) }
    context "degree > 0" do
      let(:degree) { 5.625 }
      it { expect(subject).to be_eql("E 5 degree 37 minute 30.0 second") }
    end

    context "degree < 0" do
      let(:degree) { -5.625 }
      it { expect(subject).to be_eql("W 5 degree 37 minute 30.0 second") }
    end

  end


  describe "latitude_to_html" do
    subject { obj.latitude_to_html }
    let(:obj){ FactoryGirl.create(:place, name: "test", latitude: degree) }
    context "degree > 0" do
      let(:degree) { 5.625 }
      it { expect(subject).to be_eql("N5&deg;37&prime;30.0&Prime;") }
    end

    context "degree < 0" do
      let(:degree) { -5.625 }
      it { expect(subject).to be_eql("S5&deg;37&prime;30.0&Prime;") }
    end

  end

  describe "longitude_to_html" do
    subject { obj.longitude_to_html }
    let(:obj){ FactoryGirl.create(:place, name: "test", longitude: degree) }
    context "degree > 0" do
      let(:degree) { 5.625 }
      it { expect(subject).to be_eql("E5&deg;37&prime;30.0&Prime;") }
    end

    context "degree < 0" do
      let(:degree) { -5.625 }
      it { expect(subject).to be_eql("W5&deg;37&prime;30.0&Prime;") }
    end

  end

end
 