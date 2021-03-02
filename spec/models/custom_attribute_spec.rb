require 'spec_helper'

describe CustomAttribute do
  describe "validates" do
    describe "name" do
      let(:obj) { FactoryBot.build(:custom_attribute, name: name, sesar_name: nil) }
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
      context "is unique" do
        let(:name) { "unique_name" }
        before { FactoryBot.create(:custom_attribute, name: "foo") }
        it { expect(obj).to be_valid }
      end
      context "is not unique" do
        let(:name) { "not_unique_name" }
        before { FactoryBot.create(:custom_attribute, name: name) }
        it { expect(obj).not_to be_valid }
      end
    end
    describe "sesar_name" do
      let(:obj) { FactoryBot.build(:custom_attribute, sesar_name: sesar_name) }
      context "is 255 characters" do
        let(:sesar_name) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:sesar_name) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
      context "is unique" do
        let(:sesar_name) { "unique_sesar_name" }
        before { FactoryBot.create(:custom_attribute, sesar_name: "foo") }
        it { expect(obj).to be_valid }
      end
      context "is not unique" do
        let(:sesar_name) { "sesar_name" }
        before { FactoryBot.create(:custom_attribute, sesar_name: sesar_name) }
        it { expect(obj).not_to be_valid }
      end
      context "is blank" do
        let(:sesar_name) { "" }
        before { FactoryBot.create(:custom_attribute, sesar_name: sesar_name) }
        it { expect(obj).to be_valid }
      end
    end
  end
end
