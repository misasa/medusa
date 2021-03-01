require 'spec_helper'

describe AnalysisDecorator do
  let(:obj) { FactoryBot.create(:analysis).decorate }
  let(:user) { FactoryBot.create(:user) }
  before{ User.current = user }

  describe "icon" do
    subject { AnalysisDecorator.icon }
    it { expect(subject).to eq ("<span class=\"glyphicon glyphicon-stats\"></span>") }
  end

  describe ".primary_picture" do
    let(:attachment_file){ FactoryBot.create(:attachment_file) }
    let(:picture) { obj.primary_picture(width: width, height: height) }
    let(:capybara) { Capybara.string(picture) }
    let(:body) { capybara.find("body") }
    let(:img) { body.find("img") }
    let(:width) { 250 }
    let(:height) { 250 }
    before { obj.attachment_files = [attachment_file] }
    it { expect(body).to have_css("img") }
    it { expect(img["src"]).to eq attachment_file.path }
    context "width rate greater than height rate" do
      let(:width) { 100 }
      it { expect(img["width"]).to eq width.to_s }
      it { expect(img["height"]).to be_blank }
    end
    context "width rate eq height rate" do
      it { expect(img["width"]).to eq width.to_s }
      it { expect(img["height"]).to be_blank }
    end
    context "width rate less than height rate" do
      let(:height) { 100 }
      it { expect(img["width"]).to be_blank }
      it { expect(img["height"]).to eq height.to_s }
    end
  end
end
