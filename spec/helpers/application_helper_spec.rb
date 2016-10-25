require 'spec_helper'

describe ApplicationHelper do

  describe "#format_date" do
    subject { helper.format_date(date) }
    context "date is nil" do
      let(:date) { nil }
      it { expect(subject).to eq "" }
    end
    context "date is blank" do
      let(:date) { "" }
      it { expect(subject).to eq "" }
    end
    context "date is '2014/01/01'" do
      let(:date) { '2014/01/01' }
      it { expect(subject).to eq "2014-01-01" }
    end
    context "date is '2014-01-01 00:00:00 UTC'" do
      let(:date) { '2014-01-01 00:00:00 UTC' }
      it { expect(subject).to eq "2014-01-01" }
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
    context "time is 36 hour ago" do
      let(:time) { now - ((60*60*36)) }
      it { expect(subject).to eq time.to_date }
    end
  end

  describe "#error_notification" do
    subject { helper.error_notification(errors) }
    let(:render_param) { {partial: "parts/error_notification", locals: {errors: errors}} }
    context "errors is nil" do
      let(:errors) { nil }
      it { expect(subject).to be_nil }
    end
    context "errors is blank" do
      let(:errors) { [] }
      it { expect(subject).to be_nil }
    end
    context "errors is present" do
      let(:errors) { ["error"] }
      it do
        expect(helper).to receive(:render).with(render_param)
        subject
      end
    end
  end
  
  describe "#li_if_exist" do
    after { helper.li_if_exist(prefix, value) }
    let(:prefix) { "pre: " }
    context "value is nil" do
      let(:value) { nil }
      it { expect(helper).not_to receive(:content_tag) }
    end
    context "value is not nil" do
      let(:value) { "value" }
      it { expect(helper).to receive(:content_tag).with(:li, "pre: value", {}, false) }
    end
  end

  describe "#data_count" do
    subject { helper.data_count(array) }
    context "array size is 0" do
      let(:array) { [] }
      it { expect(subject).to eq "" }
    end
    context "array size is 1" do
      let(:array) { [:a] }
      it { expect(subject).to eq " (1)" }
    end
    context "array size is 2" do
      let(:array) { [:a, :b] }
      it { expect(subject).to eq " (2)" }
    end
  end

  describe "#active_if_current" do
    subject { helper.active_if_current(tabname) }
    context "param[:tab] is present" do
      before { allow(helper).to receive(:params).and_return({tab: "box"}) }
      context "param[:tab] == tabname" do
        let(:tabname) { "box" }
        it { expect(subject).to eq " active" }
      end
      context "param[:tab] != tabname" do
        let(:tabname) { "specimen" }
        it { expect(subject).to eq nil }
      end
    end
    context "param[:tab] is nil" do
      before { allow(helper).to receive(:params).and_return({tab: nil}) }
      context "tabname is at-a-glance" do
        let(:tabname) { "at-a-glance" }
        it { expect(subject).to eq " active" }
      end
      context "tabname is not at-a-glance" do
        let(:tabname) { "box" }
        it { expect(subject).to eq nil }
      end
    end
  end

  describe "#tab_param" do
    subject { helper.tab_param(filename) }
    let(:filename){"_specimen.html.erb"}
    it { expect(subject).to eq "?tab=specimen"}
  end

  describe "#hidden_tabname_tag" do
    subject { helper.hidden_tabname_tag(filename) }
    let(:filename){"_specimen.html.erb"}
    it { expect(subject).to eq hidden_field_tag(:tab,"specimen")}
  end
  
  describe "#specimen_ghost" do
    subject { helper.specimen_ghost(obj, html_class) }
    let(:html_class) { "test" }
    context "obj is Specimen" do
      let(:obj) { FactoryGirl.build(:specimen, quantity: quantity) }
      context "quantity < 0" do
        let(:quantity) { -1 }
        it { expect(subject).to eq "test ghost" }
      end
      context "quantity = 0" do
        let(:quantity) { 0 }
        it { expect(subject).to eq "test" }
      end
      context "quantity > 0" do
        let(:quantity) { 1 }
        it { expect(subject).to eq "test" }
      end
    end
    context "obj is not Specimen" do
      let(:obj) { FactoryGirl.create(:box) }
      it { expect(subject).to eq "test" }
    end
  end

end
