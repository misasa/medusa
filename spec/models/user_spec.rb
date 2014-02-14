require "spec_helper"

describe User do
  describe "self.current" do
    let(:user){ FactoryGirl.create(:user) }
    before { User.current = user }
    it{ expect(User.current.id).to eq user.id }
  end
end
