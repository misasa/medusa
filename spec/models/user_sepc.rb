require "spec_helper"

describe User do
  describe "self.current" do
    user = User.new(:id => 1)
    User.current = user
    it{expect(User.current.id).to eq 1}
  end
end