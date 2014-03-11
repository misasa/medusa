require 'spec_helper'
include ActionDispatch::TestProcess

describe AttachmentFileDecorator do
  let(:user){ FactoryGirl.create(:user)}
  let(:attachment_file){FactoryGirl.create(:attachment_file).decorate}
  before{User.current = user}

  describe ".original_width" do
    subject{ attachment_file.original_width }
    before{attachment_file.original_geometry = original_geometry}
    context "original_geometry is blank" do
      let(:original_geometry){nil}
      it {expect(subject).to eq ""}
    end
    context "original_geometry is not blank" do
      let(:original_geometry){"111x222"}
      it {expect(subject).to eq 111}
    end
  end

  describe ".original_height" do
    subject{ attachment_file.original_height }
    before{attachment_file.original_geometry = original_geometry}
    context "original_geometry is blank" do
      let(:original_geometry){nil}
      it {expect(subject).to eq ""}
    end
    context "original_geometry is not blank" do
      let(:original_geometry){"111x222"}
      it {expect(subject).to eq 222}
    end
  end

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
end
