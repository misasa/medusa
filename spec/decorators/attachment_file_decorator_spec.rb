require 'spec_helper'
include ActionDispatch::TestProcess

describe AttachmentFileDecorator do
  let(:user){ FactoryGirl.create(:user)}
  let(:attachment_file){FactoryGirl.create(:attachment_file).decorate}
  before{User.current = user}

  describe ".picture" do
    let(:picture) { attachment_file.picture(width: width, height: height) }
    let(:capybara) { Capybara.string(picture) }
    let(:body) { capybara.find("body") }
    let(:img) { body.find("img") }
    let(:width) { 250 }
    let(:height) { 250 }
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

  describe ".image_link" do
    let(:image_link) { attachment_file.image_link }
    let(:capybara) { Capybara.string(image_link) }
    let(:body) { capybara.find("body") }
    let(:link) { body.find("a") }
    let(:img) { body.find("img") }
    it { expect(body).to have_css("a") }
    context "file is image" do
      before { allow(attachment_file).to receive(:image?).and_return(true) }
      it { expect(link).to have_css("img") }
      it { expect(link).to_not have_css("span.glyphicon") }
    end
    context "file is not image" do
      before { allow(attachment_file).to receive(:image?).and_return(false) }
      it { expect(link).to_not have_css("img") }
      it { expect(link).to have_css("span.glyphicon") }
    end
  end

  describe ".to_tex" do
    subject{ attachment_file.to_tex }
    it {expect(subject).to include "\\begin{overpic}"}
    it {expect(subject).to include "\\end{overpic}"}
    context "spots is empty " do
      before{attachment_file.spots.clear}
      it {expect(subject).not_to include "{\\footnotesize \\circle{0.7} \\url{"}
    end
    context "spots is not empty " do
      let(:spot){FactoryGirl.create(:spot)}
      before{attachment_file.spots << spot }
      it {expect(subject).to include "{\\footnotesize \\circle{0.7} \\url{"}
      context "target_uid is empty" do
        before{attachment_file.spots[0].target_uid = ""}
        it {expect(subject).not_to include " % target_uid"}
      end
      context "target_uid is not empty" do
        before{attachment_file.spots[0].target_uid = "target_uid"}
        it {expect(subject).to include " % target_uid"}
      end
      context "affine_matrix is empty" do
        before{attachment_file.affine_matrix = []}
        it {expect(subject).not_to include " % \\vs("}
      end
      context "affine_matrix is not empty" do
        before{attachment_file.affine_matrix = [1,0,0,0,1,0,0,0,1]}
        it {expect(subject).to include " % \\vs("}
      end
    end
    context "affine_matrix is empty" do
      before{attachment_file.affine_matrix = []}
      it {expect(subject).not_to include "%%scale"}
      it {expect(subject).not_to include "\\put(1,1){\\line(1,0)"}
    end
    context "affine_matrix is not empty" do
      before{attachment_file.affine_matrix = [1,0,0,0,1,0,0,0,1]}
      it {expect(subject).to include "%%scale"}
      it {expect(subject).to include "\\put(1,1){\\line(1,0)"}
    end
  end




end
