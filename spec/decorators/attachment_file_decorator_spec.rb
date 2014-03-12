require 'spec_helper'
include ActionDispatch::TestProcess

describe AttachmentFileDecorator do
  let(:user){ FactoryGirl.create(:user)}
  let(:attachment_file){FactoryGirl.create(:attachment_file).decorate}
  before{User.current = user}

  describe ".picture" do
    subject{ attachment_file.picture }
    let(:attachment_file) { AttachmentFile.new(data: fixture_file_upload("/files/test_image.jpg",'image/jpeg')).decorate}
    before{attachment_file.save}
    it {expect(subject).to include "<img"}
    it {expect(subject).to include "/>"}
    it {expect(subject).to include "width=\"250\""}
    it {expect(subject).to include "height=\"250\""}
    it {expect(subject).to include "src=\"#{attachment_file.path}\""}
    it {expect(subject).to include "alt=\"Test image\""}
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
