require 'spec_helper'

describe CustomAttribute do
  describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:custom_attribute, name: name) }
      context "is presence" do
        let(:name) { "sample_name" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:name) { "" }
        it { expect(obj).not_to be_valid }
      end
      context "is 255 characters" do
        let(:name) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:name) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
    end
    describe "sesar_name" do
      let(:obj) { FactoryGirl.build(:custom_attribute, sesar_name: sesar_name) }
      context "is presence" do
        let(:sesar_name) { "sample_sesar_name" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:sesar_name) { "" }
        it { expect(obj).to be_valid }
      end
      context "is 255 characters" do
        let(:sesar_name) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:sesar_name) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
    end
  end
end
