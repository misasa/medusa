require 'spec_helper'
include ActionDispatch::TestProcess

describe TableDecorator do
  let(:obj) { FactoryBot.create(:table).decorate }
  describe "#name_with_id" do
    subject { obj.name_with_id }
    it { expect(subject).to include(obj.caption) }
    it { expect(subject).to include(obj.global_id) }
    it { expect(subject).to include("<span class=\"fas fa-table\"></span>") } 
  end
end
