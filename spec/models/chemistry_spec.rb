require 'spec_helper'

describe Chemistry do

  describe "#display_name" do
    subject { chemistry.display_name }
    let(:chemistry) { FactoryGirl.build(:chemistry, measurement_item: measurement_item, unit: unit, value: value) }
    let(:measurement_item) { FactoryGirl.create(:measurement_item, unit: unit, display_in_html: display_in_html, nickname: nickname) }
    let(:unit) { FactoryGirl.create(:unit) }
    let(:value) { 1 }
    let(:display_in_html) { "HTML" }
    let(:nickname) { "nickname" }
    context "measurement_item.display_in_html is present" do
      it { expect(subject).to eq "HTML: 1.00" }
    end
    context "measurement_item.display_in_html is nil" do
      let(:display_in_html) { nil }
      it { expect(subject).to eq "nickname: 1.00" }
    end
  end

end
