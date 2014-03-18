require 'spec_helper'

describe MeasurementItem do

  describe "validates" do
    describe "nickname" do
      let(:obj) { FactoryGirl.build(:measurement_item, nickname: nickname) }
      context "is presence" do
        let(:nickname) { "sample_measurement_item" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:nickname) { "" }
        it { expect(obj).not_to be_valid }
      end
      context "is 255 characters" do
        let(:nickname) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:nickname) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
    end
  end

  describe ".display_name" do
    subject{obj.display_name}
    let(:obj) { FactoryGirl.build(:measurement_item, nickname: nickname,display_in_html: display_in_html) }
    context "display_in_html is not blank" do
      let(:nickname){"nickname"}
      let(:display_in_html){"display_in_html"}
      it {expect(subject).to eq display_in_html}
    end
    context "display_in_html is blank" do
      let(:nickname){"nickname"}
      let(:display_in_html){""}
      it {expect(subject).to eq nickname}
    end
  end
end
