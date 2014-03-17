require 'spec_helper'

describe BibDecorator do
  let(:user) { FactoryGirl.create(:user) }
  before{ User.current = user }
  
  describe ".name_with_id" do
  end
  
end
