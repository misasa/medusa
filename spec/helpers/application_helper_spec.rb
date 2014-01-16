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

end
