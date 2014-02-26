require 'spec_helper'

describe PlaceHelper do

  describe ".format_latitude" do
    subject{ helper.format_latitude(latitude) }
    context "latitude is null" do
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

  describe ".format_longitude" do
    subject{ helper.format_longitude(longitude) }
    context "longitude is null" do
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

  describe ".format_elevation" do
    subject{ helper.format_elevation(elevation) }
    context "elevation nil" do
      let(:elevation) { nil }
      it { expect(subject).to eq "" }
    end
    context "elevation not nill" do
      let(:elevation) {9.9 }
      it { expect(subject).to eq "9.9" }
    end
  end

  describe ".format_stones_summary" do
    subject{ helper.format_stones_summary(stones) }
    context "count 0" do
      let(:stones){[]}
      it {expect(subject).to eq " [0]"}
    end
    context "count 1" do
      let(:stones){[Stone.new(name: "123")]}
      it {expect(subject).to eq "123 [1]"}
    end
    context "count 2" do
      let(:stones){[Stone.new(name: "123"),Stone.new(name: "456")]}
      it {expect(subject).to eq "123, 456 [2]"}
    end
    context "length over" do
      let(:stones){[Stone.new(name: "123"),Stone.new(name: "456"),Stone.new(name: "789")]}
      it {expect(subject).to eq "123, 456,  ... [3]"}
    end
    context "length 11" do
      subject{ helper.format_stones_summary(stones,11) }
      let(:stones){[Stone.new(name: "123"),Stone.new(name: "456"),Stone.new(name: "789")]}
      it {expect(subject).to eq "123, 456, 7 ... [3]"}
    end
    context "length no limit" do
      subject{ helper.format_stones_summary(stones,nil) }
      let(:stones){[Stone.new(name: "123"),Stone.new(name: "456"),Stone.new(name: "789")]}
      it {expect(subject).to eq "123, 456, 789 [3]"}
    end
  end

  describe ".format_stones_count" do
    subject{ helper.format_stones_count(stones) }
    context "count 0" do
      let(:stones){[]}
      it {expect(subject).to eq ""}
    end
    context "count 1" do
      let(:stones){[Stone.new(name: "123")]}
      it {expect(subject).to eq "1"}
    end
    context "count 2" do
      let(:stones){[Stone.new(name: "123"),Stone.new(name: "456")]}
      it {expect(subject).to eq "2"}
    end
  end
end
