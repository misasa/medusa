require 'spec_helper'

describe SpotDecorator do
  let(:user){ FactoryGirl.create(:user)}
  let(:spot){ FactoryGirl.create(:spot, target_uid: target_uid).decorate }
  before{User.current = user}

  describe ".taget_link" do
    subject{ spot.target_link }
    context "target_uid is nil" do
      let(:target_uid) { nil }
      it { expect(subject).to eq spot.name }
    end
    context "not exists record_property" do
      let(:target_uid) { "aaa" }
      it { expect(subject).to eq spot.name }
    end
    context "exists record property" do
      let(:target_uid) { bib.global_id }
      let(:bib){FactoryGirl.create(:bib,name: "test bib")}
      context "not exists datum" do
        before { bib.destroy }
        it { expect(subject).to eq spot.name }
      end
      context "exists datum" do
        it { expect(subject).to eq "<a href=\"/bibs/#{bib.id}\">test bib</a>" }
      end
    end
  end

  describe ".target_path" do
    subject { spot.target_path }
    context "target_uid is nil" do
      let(:target_uid) { nil }
      it { expect(subject).to be_nil }
    end
    context "not exists record_property" do
      let(:target_uid) { "aaa" }
      it { expect(subject).to be_nil }
    end
    context "exists record property" do
      let(:target_uid) { bib.global_id }
      let(:bib){FactoryGirl.create(:bib,name: "test bib")}
      context "not exists datum" do
        before { bib.destroy }
        it { expect(subject).to be_nil }
      end
      context "exists datum" do
        it { expect(subject).to eq "/bibs/#{bib.id}" }
      end
    end
  end
end
