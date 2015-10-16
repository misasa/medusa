require 'spec_helper'

describe Omniauth do
  describe "validates" do
    describe "provider" do
      let(:obj) { FactoryGirl.build(:omniauth, provider: provider) }
      context "is presence" do
        let(:provider) { "provider" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:provider) { "" }
        it { expect(obj).not_to be_valid }
      end
      context "is 255 characters" do
        let(:provider) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:provider) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
    end
    
    describe "uid" do
      let(:obj) { FactoryGirl.build(:omniauth, uid: uid) }
      context "is presence" do
        let(:uid) { "123456" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:uid) { "" }
        it { expect(obj).not_to be_valid }
      end
      context "is 255 characters" do
        let(:uid) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:uid) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
    end
  end
end
