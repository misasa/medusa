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
    context "time is 27 hour ago" do
      let(:time) { now - ((60*60*27)) }
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
      it { expect(subject).to eq "(1)" }
    end
    context "array size is 2" do
      let(:array) { [:a, :b] }
      it { expect(subject).to eq "(2)" }
    end
  end

  describe "#if_active" do
    subject { helper.if_active(tabname) }
    context "tabname is nil" do
      let(:tabname) { nil }
      context "params[:tab] is nil" do
        before { allow(helper).to receive(:params).and_return({tab: nil}) }
        it { expect(subject).to eq " active" }
      end
      context "params[:tab] is present" do
        before { allow(helper).to receive(:params).and_return({tab: "tab"}) }
        it { expect(subject).to eq nil }
      end
    end
    context "tabname is present" do
      let(:tabname) { "tabname" }
      context "params[:tab] equal tabname" do
        before { allow(helper).to receive(:params).and_return({tab: "tabname"}) }
        it { expect(subject).to eq " active" }
      end
      context "params[:tab] not equal tabname" do
        before { allow(helper).to receive(:params).and_return({tab: "tab"}) }
        it { expect(subject).to eq nil }
      end
    end
  end

end
