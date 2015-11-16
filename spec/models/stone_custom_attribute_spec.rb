require 'spec_helper'

describe StoneCustomAttribute do
  describe "validates" do
    describe "value" do
      let(:obj) { FactoryGirl.build(:stone_custom_attribute, value: value, stone_id: 1, custom_attribute_id: 1) }
      context "is 255 characters" do
        let(:value) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:value) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
      describe "uniqueness" do
        context "stone_id is duplicate" do
          context "custom_attribute_id is duplicate" do
            context "value is duplicate" do
              let(:value) { "not_unique_value" }
              before { FactoryGirl.create(:stone_custom_attribute, stone_id: obj.stone_id, custom_attribute_id: obj.custom_attribute_id, value: value) }
              it { expect(obj).not_to be_valid }
            end
            context "value is unique" do
              let(:value) { "unique_value" }
              before { FactoryGirl.create(:stone_custom_attribute, stone_id: obj.stone_id, custom_attribute_id: obj.custom_attribute_id, value: "foo") }
              it { expect(obj).to be_valid }
            end
          end
          context "custom_attribute_id is unique" do
            context "value is duplicate" do
              let(:value) { "not_unique_value" }
              before { FactoryGirl.create(:stone_custom_attribute, stone_id: obj.stone_id, custom_attribute_id: (obj.custom_attribute_id + 1), value: value) }
              it { expect(obj).to be_valid }
            end
            context "value is unique" do
              let(:value) { "unique_value" }
              before { FactoryGirl.create(:stone_custom_attribute, stone_id: obj.stone_id, custom_attribute_id: (obj.custom_attribute_id + 1), value: "foo") }
              it { expect(obj).to be_valid }
            end
          end
        end
        context "stone_id is unique" do
          context "custom_attribute_id is duplicate" do
            context "value is duplicate" do
              let(:value) { "not_unique_value" }
              before { FactoryGirl.create(:stone_custom_attribute, stone_id: (obj.stone_id + 1), custom_attribute_id: obj.custom_attribute_id, value: value) }
              it { expect(obj).to be_valid }
            end
            context "value is unique" do
              let(:value) { "unique_value" }
              before { FactoryGirl.create(:stone_custom_attribute, stone_id: (obj.stone_id + 1), custom_attribute_id: obj.custom_attribute_id, value: "foo") }
              it { expect(obj).to be_valid }
            end
          end
          context "custom_attribute_id is unique" do
            context "value is duplicate" do
              let(:value) { "not_unique_value" }
              before { FactoryGirl.create(:stone_custom_attribute, stone_id: (obj.stone_id + 1), custom_attribute_id: (obj.custom_attribute_id + 1), value: value) }
              it { expect(obj).to be_valid }
            end
            context "value is unique" do
              let(:value) { "unique_value" }
              before { FactoryGirl.create(:stone_custom_attribute, stone_id: (obj.stone_id + 1), custom_attribute_id: (obj.custom_attribute_id + 1), value: "foo") }
              it { expect(obj).to be_valid }
            end
          end
        end
      end
    end
  end
end
