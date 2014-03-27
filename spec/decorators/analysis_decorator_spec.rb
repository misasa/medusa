require 'spec_helper'

describe AnalysisDecorator do
  let(:user) { FactoryGirl.create(:user) }
  before{ User.current = user }

  describe ".primary_picture" do
    after { analysis.primary_picture(width: width, height: height) }
    let(:analysis) { FactoryGirl.create(:analysis).decorate }
    let(:width) { 250 }
    let(:height) { 250 }
    before { analysis }
    context "attachment_files is null" do
      let(:attachment_file_1) { [] }
      it { expect(helper).not_to receive(:image_tag) }
    end
    context "attachment_files is not null" do
      let(:attachment_file_1) { FactoryGirl.create(:attachment_file, name: "att_1") }
      before { analysis.attachment_files << attachment_file_1 }
      it { expect(helper).to receive(:image_tag).with(attachment_file_1.path, width: width, height: height) }
    end
  end
end
