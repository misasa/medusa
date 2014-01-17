require 'spec_helper'

describe ApplicationHelper do

  describe "#navbar_path" do
    subject { helper.navbar_path(controller_name) }
    context "controller_name is nil" do
      let(:controller_name) { nil }
      it { expect(subject).to eq "layouts/navbar_default" }
    end
    context "controller_name is 'analyses'" do
      let(:controller_name) { "analyses" }
      it { expect(subject).to eq "layouts/navbar_default" }
    end
    context "controller_name is 'bibs'" do
      let(:controller_name) { "bibs" }
      it { expect(subject).to eq "layouts/navbar_default" }
    end
    context "controller_name is 'boxes'" do
      let(:controller_name) { "boxes" }
      it { expect(subject).to eq "layouts/navbar_default" }
    end
    context "controller_name is 'facade'" do
      let(:controller_name) { "facade" }
      it { expect(subject).to eq "layouts/navbar_default" }
    end
    context "controller_name is 'files'" do
      let(:controller_name) { "files" }
      it { expect(subject).to eq "layouts/navbar_default" }
    end
    context "controller_name is 'places'" do
      let(:controller_name) { "places" }
      it { expect(subject).to eq "layouts/navbar_default" }
    end
    context "controller_name is 'stones'" do
      let(:controller_name) { "stones" }
      it { expect(subject).to eq "layouts/navbar_default" }
    end
    context "controller_name is 'system_preferences'" do
      let(:controller_name) { "system_preferences" }
      it { expect(subject).to eq "layouts/navbar_system" }
    end
    context "controller_name is 'users'" do
      let(:controller_name) { "users" }
      it { expect(subject).to eq "layouts/navbar_system" }
    end
    context "controller_name is 'groups'" do
      let(:controller_name) { "groups" }
      it { expect(subject).to eq "layouts/navbar_system" }
    end
    context "controller_name is 'classifications'" do
      let(:controller_name) { "classifications" }
      it { expect(subject).to eq "layouts/navbar_system" }
    end
    context "controller_name is 'physical_forms'" do
      let(:controller_name) { "physical_forms" }
      it { expect(subject).to eq "layouts/navbar_system" }
    end
    context "controller_name is 'box_types'" do
      let(:controller_name) { "box_types" }
      it { expect(subject).to eq "layouts/navbar_system" }
    end
    context "controller_name is 'measurement_items'" do
      let(:controller_name) { "measurement_items" }
      it { expect(subject).to eq "layouts/navbar_system" }
    end
    context "controller_name is 'measurement_categories'" do
      let(:controller_name) { "measurement_categories" }
      it { expect(subject).to eq "layouts/navbar_system" }
    end
  end

  describe "#difference_from_now" do
    subject { helper.difference_from_now(time) }
    before { allow(Time).to receive(:now).and_return(now) }
    let(:now) { Time.local(2014,1,1,12,0,0) }
    context "time is nil" do
      let(:time) { nil }
      it { expect(subject).to be_nil }
    end
    context "time equal now" do
      let(:time) { now }
      it { expect(subject).to eq "0 s ago" }
    end
    context "time is 59 sec ago" do
      let(:time) { now - 59 }
      it { expect(subject).to eq "59 s ago" }
    end
    context "time is 60 sec ago" do
      let(:time) { now - 60 }
      it { expect(subject).to eq "1 m ago" }
    end
    context "time is (59m and 59s) ago" do
      let(:time) { now - ((60*60)-1) }
      it { expect(subject).to eq "59 m ago" }
    end
    context "time is 60 min ago" do
      let(:time) { now - (60*60) }
      it { expect(subject).to eq "1 h ago" }
    end
    context "time is 12 hour ago" do
      let(:time) { now - (60*60*12) }
      it { expect(subject).to eq "12 h ago" }
    end
    context "time is (12h and 1s) ago" do
      let(:time) { now - ((60*60*12)+1) }
      it { expect(subject).to eq "yesterday, 23:59" }
    end
    context "time is 27 hour ago" do
      let(:time) { now - ((60*60*27)) }
      it { expect(subject).to eq time.to_date }
    end
  end

end
