require 'spec_helper'

describe Omniauth do
  describe "validates" do
    describe "provider" do
      let(:obj) { FactoryBot.build(:omniauth, provider: provider) }
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
      let(:obj) { FactoryBot.build(:omniauth, uid: uid) }
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
  
  describe "find_user_by_auth" do
    subject { Omniauth.find_user_by_auth(auth) }
    before { omniauth }
    let(:auth) { double(:auth, provider: provider, uid: uid) }
    let(:provider) { "sample_provider" }
    let(:uid) { "12345" }
    let(:omniauth) { FactoryBot.create(:omniauth, provider: provider, uid: uid, user: user) }
    let(:user) { FactoryBot.create(:user) }
    context "auth matches omniauth record" do
      it { expect(subject).to eq user }
    end
    context "auth not matches omniauth record" do
      let(:auth) { double(:auth, provider: :foo, uid: :bar) }
      it { expect(subject).to be_nil }
    end
  end
end
