require 'spec_helper'

describe SpecimenQuantity do

  describe "validates" do
    describe "quantity" do
      let(:obj) { FactoryGirl.build(:specimen_quantity, quantity: quantity) }
      context "num" do
        let(:quantity){ "1" }
        it { expect(obj).to be_valid }
        context "0" do
          let(:quantity){ "0" }
          it { expect(obj).to be_valid }
        end
        context "-1" do
          let(:quantity){ "-1" }
          it { expect(obj).not_to be_valid }
        end
      end
      context "str" do
        let(:quantity){ "a" }
        it { expect(obj).not_to be_valid }
      end
    end
  end
end
