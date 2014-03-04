require "spec_helper"

describe Place do

  describe ".readable_neighbors" do
    let(:user){ FactoryGirl.create(:user,administrator: false) }
    let(:place){FactoryGirl.create(:place,latitude:0,longitude:0)}
    let(:place1){FactoryGirl.create(:place,name:1,latitude:9,longitude:0)}
    let(:place2){FactoryGirl.create(:place,name:2,latitude:8,longitude:0)}
    let(:place3){FactoryGirl.create(:place,name:3,latitude:7,longitude:0)}
    let(:place4){FactoryGirl.create(:place,name:4,latitude:6,longitude:0)}
    let(:place5){FactoryGirl.create(:place,name:5,latitude:5,longitude:0)}
    let(:place6){FactoryGirl.create(:place,name:6,latitude:4,longitude:0)}
    let(:place7){FactoryGirl.create(:place,name:7,latitude:3,longitude:0)}
    let(:place8){FactoryGirl.create(:place,name:8,latitude:2,longitude:0)}
    let(:place9){FactoryGirl.create(:place,name:9,latitude:1,longitude:0)}
    let(:place10){FactoryGirl.create(:place,name:10,latitude:10,longitude:0)}
    let(:place11){FactoryGirl.create(:place,name:11,latitude:11,longitude:0)}
    before do
      User.current = user
      place
    end
    context "" do
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
      let(:place_other){FactoryGirl.create(:place,latitude:0,longitude:0)}
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
      let(:place){FactoryGirl.create(:place,latitude: nil)}
      it{expect(place.distance_from(0,0)).to eq Float::DIG}
    end

    context "lognitude.blank" do
      let(:place){FactoryGirl.create(:place,longitude: nil)}
      it{expect(place.distance_from(0,0)).to eq Float::DIG}
    end

    context "praram latitude.blank" do
      let(:place){FactoryGirl.create(:place,latitude:35.68107370561057,longitude:139.76707935333252)}
      it{expect(place.distance_from(nil,132.75656819343567)).to eq Float::DIG}
    end

    context "lognitude.blank" do
      let(:place){FactoryGirl.create(:place,latitude:35.68107370561057,longitude:139.76707935333252)}
      it{expect(place.distance_from(35.36069738459534,nil)).to eq Float::DIG}
    end

    context "" do
      let(:place){FactoryGirl.create(:place,latitude:35.681309,longitude:139.766048)}
      it{expect(place.distance_from(35.36068,132.756545).round(3)).to eq 781.098}

    end
  end

  describe "self.deg2rad" do
    it{expect(Place.deg2rad(180).round(4)).to eq 3.14159.round(4)}
  end

end
