require 'spec_helper'

describe PlaceDecorator do
  let(:user){ FactoryGirl.create(:user)}
  let(:latitude) { 0.0 }
  let(:longitude) { 0.0 }
  let(:elevation) { 0.0 }
  let(:place){FactoryGirl.create(:place,latitude: latitude,longitude: longitude,elevation: elevation).decorate}
  before{User.current = user}

  describe ".latitude_to_text" do
    subject{ place.latitude_to_text }
    context "latitude is blank" do
      let(:latitude) {nil }
      it { expect(subject).to eq "" }
    end
    context "latitude S" do
      let(:latitude) { -9.9999 }
      it { expect(subject).to eq "9.9999 S" }
    end
    context "latitude N" do
      let(:latitude) { 9.9999 }
      it { expect(subject).to eq "9.9999 N" }
    end
  end

  describe ".longitude_to_text" do
    subject{ place.longitude_to_text }
    context "longitude is blank" do
      let(:longitude) {nil }
      it { expect(subject).to eq "" }
    end
    context "longitude W" do
      let(:longitude) { -9.9999 }
      it { expect(subject).to eq "9.9999 W" }
    end
    context "longitude E" do
      let(:longitude) { 9.9999 }
      it { expect(subject).to eq "9.9999 E" }
    end
  end

  describe ".elevation_to_text" do
    subject{ place.elevation_to_text }
    context "elevation nil" do
      let(:elevation) { nil }
      it { expect(subject).to eq "" }
    end
    context "elevation not nill" do
      let(:elevation) {9.9 }
      it { expect(subject).to eq "9.9" }
    end
  end

  describe ".stones_summary" do
    subject{ place.stones_summary }
    context "count 0" do
      before{place.stones.clear}
      it {expect(subject).to eq " [0]"}
    end
    context "count 1" do
      let(:stones){[Stone.new(name: "123")]}
      before{place.stones << stones}
      it {expect(subject).to eq "123 [1]"}
    end
    context "count 2" do
      let(:stones){[Stone.new(name: "123"),Stone.new(name: "456")]}
      before{place.stones << stones}
      it {expect(subject).to eq "123, 456 [2]"}
    end
    context "length over" do
      let(:stones){[Stone.new(name: "123"),Stone.new(name: "456"),Stone.new(name: "789")]}
      before{place.stones << stones}
      it {expect(subject).to eq "123, 456,  ... [3]"}
    end
    context "length 11" do
      subject{ place.stones_summary(11) }
      let(:stones){[Stone.new(name: "123"),Stone.new(name: "456"),Stone.new(name: "789")]}
      before{place.stones << stones}
      it {expect(subject).to eq "123, 456, 7 ... [3]"}
    end
    context "length no limit" do
      subject{ place.stones_summary(nil) }
      let(:stones){[Stone.new(name: "123"),Stone.new(name: "456"),Stone.new(name: "789")]}
      before{place.stones << stones}
      it {expect(subject).to eq "123, 456, 789 [3]"}
    end
  end

  describe ".stones_count" do
    subject{ place.stones_count() }
    context "count 0" do
      before{place.stones.clear}
      it {expect(subject).to eq ""}
    end
    context "count 1" do
      let(:stones){[Stone.new(name: "123")]}
      before{place.stones << stones}
      it {expect(subject).to eq "1"}
    end
    context "count 2" do
      let(:stones){[Stone.new(name: "123"),Stone.new(name: "456")]}
      before{place.stones << stones}
      it {expect(subject).to eq "2"}
    end
  end

  describe ".country_name" do
    subject{ place.country_name }
    context "get country name ng" do
      let(:latitude){360}
      let(:longitude){360}
      it {expect(subject).to eq ""}
    end
    context "get country name" do
      let(:latitude){35.3606}
      let(:longitude){132.75558}
      it {expect(subject).to eq "Japan"}
    end
  end

  describe ".nearby_geonames" do
    subject{ place.nearby_geonames }
    let(:latitude){35.3606}
    let(:longitude){132.75558}
    it {expect(subject.count).to eq 10}
  end

  describe ".readable_neighbors" do
    let(:user){ FactoryGirl.create(:user,administrator: false) }
    let(:place){FactoryGirl.create(:place,latitude:0,longitude:0).decorate}
    let(:place1){FactoryGirl.create(:place,name:1,latitude:9,longitude:0).decorate}
    let(:place2){FactoryGirl.create(:place,name:2,latitude:8,longitude:0).decorate}
    let(:place3){FactoryGirl.create(:place,name:3,latitude:7,longitude:0).decorate}
    let(:place4){FactoryGirl.create(:place,name:4,latitude:6,longitude:0).decorate}
    let(:place5){FactoryGirl.create(:place,name:5,latitude:5,longitude:0).decorate}
    let(:place6){FactoryGirl.create(:place,name:6,latitude:4,longitude:0).decorate}
    let(:place7){FactoryGirl.create(:place,name:7,latitude:3,longitude:0).decorate}
    let(:place8){FactoryGirl.create(:place,name:8,latitude:2,longitude:0).decorate}
    let(:place9){FactoryGirl.create(:place,name:9,latitude:1,longitude:0).decorate}
    let(:place10){FactoryGirl.create(:place,name:10,latitude:10,longitude:0).decorate}
    let(:place11){FactoryGirl.create(:place,name:11,latitude:11,longitude:0).decorate}
    before do
      User.current = user
      place
    end
    context "count >= 10" do
      before do
        place1
        place2
        place3
        place4
        place5
        place6
        place7
        place8
        place9
        place10
        place11
      end
      it {expect(place.readable_neighbors(user).count).to eq 10}
      it {expect(place.readable_neighbors(user).include?(place)).to eq false}
      it {expect(place.readable_neighbors(user)[0]).to eq place9}
      it {expect(place.readable_neighbors(user)[1]).to eq place8}
      it {expect(place.readable_neighbors(user)[2]).to eq place7}
      it {expect(place.readable_neighbors(user)[3]).to eq place6}
      it {expect(place.readable_neighbors(user)[4]).to eq place5}
      it {expect(place.readable_neighbors(user)[5]).to eq place4}
      it {expect(place.readable_neighbors(user)[6]).to eq place3}
      it {expect(place.readable_neighbors(user)[7]).to eq place2}
      it {expect(place.readable_neighbors(user)[8]).to eq place1}
      it {expect(place.readable_neighbors(user)[9]).to eq place10}
      it {expect(place.readable_neighbors(user).include?(place11)).to eq false}
    end

    context "count < 10" do
      before do
        place1
        place2
        place3
        place4
      end
      it {expect(place.readable_neighbors(user).count).to eq 4}
    end
    context "none readable" do
      let(:user_other){ FactoryGirl.create(:user,username: "user_other",email: "user_other@test.co.jp",administrator: false) }
      let(:place_other){FactoryGirl.create(:place,latitude:0,longitude:0).decorate}
      before do
        place1
        place_other.record_property.user_id = user_other.id
        place_other.save
      end
      it {expect(place.readable_neighbors(user).count).to eq 1}
      it {expect(place.readable_neighbors(user).include?(place)).to eq false}
      it {expect(place.readable_neighbors(user).include?(place1)).to eq true}
      it {expect(place.readable_neighbors(user).include?(place_other)).to eq false}
    end
  end
  describe ".deistance_from" do
    context "latitude.blank" do
      let(:latitude){nil}
      let(:longitude){139.76707935333252}
      it{expect(place.distance_from(0,0)).to eq Float::DIG}
    end

    context "longitude.blank" do
      let(:latitude){35.68107370561057}
      let(:longitude){nil}
      it{expect(place.distance_from(0,0)).to eq Float::DIG}
    end

    context "praram latitude.blank" do
      let(:latitude){35.68107370561057}
      let(:longitude){139.76707935333252}
      it{expect(place.distance_from(nil,132.75656819343567)).to eq Float::DIG}
    end

    context "param longitude.blank" do
      let(:latitude){35.68107370561057}
      let(:longitude){139.76707935333252}
      it{expect(place.distance_from(35.36069738459534,nil)).to eq Float::DIG}
    end

    context "latitude,longitude all not blank" do
      let(:latitude){35.36068}
      let(:longitude){132.756545}
      it{expect(place.distance_from(35.681309,139.766048).round(3)).to eq 781.098}

    end
  end

  describe "self.deg2rad" do
    it{expect(PlaceDecorator.deg2rad(180).round(4)).to eq 3.14159.round(4)}
  end

end
