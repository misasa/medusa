require "spec_helper"

describe Bib do
  describe "constants" do
    describe "LABEL_HEADER" do
      subject { Bib::LABEL_HEADER }
      it { expect(subject).to eq ["Id","Name","Authors"] }
    end
  end

  describe ".doi_link_url" do
    subject { bib.doi_link_url }
    let(:bib) { FactoryGirl.create(:bib, doi: doi_1) }
    context "doi is nil" do
      let(:doi_1) { nil }
      it { expect(subject).to be_nil }
    end
    context "doi is not nil" do
      let(:doi_1) { "test" }
      it { expect(subject).to eq "http://dx.doi.org/test" }
    end
  end
  
  describe "#primary_pdf_attachment_file" do
    subject { bib.primary_pdf_attachment_file }
    let(:bib) { FactoryGirl.build(:bib) }
    before do
      bib
      allow(bib).to receive(:pdf_files).and_return(pdf_files)
    end
    context "bib.pdf_files is nil" do
      let(:pdf_files) { nil }
      it { expect(subject).to be_nil }
    end
    context "bib.pdf_files is blank" do
      let(:pdf_files) { [] }
      it { expect(subject).to be_nil }
    end
    context "bib.pdf_files is present" do
      let(:pdf_files) { ["a","b","c"] }
      it { expect(subject).to eq "a" }
    end
  end

  describe "#build_label" do
    subject { bib.build_label }
    let(:bib) { FactoryGirl.create(:bib, name: "foo") }
    let(:author_1) { FactoryGirl.create(:author, name: "bar") }
    let(:author_2) { FactoryGirl.create(:author, name: "baz") }
    before do
      bib.authors << author_1
      bib.authors << author_2
    end
    it { expect(subject).to eq "Id,Name,Authors\n#{bib.global_id},foo,bar baz\n" }
  end

  describe ".build_bundle_label" do
    subject { Bib.build_bundle_label(bibs) }
    let(:bibs) { Bib.all }
    let(:bib_1) { FactoryGirl.create(:bib, name: "bib_1") }
    let(:bib_2) { FactoryGirl.create(:bib, name: "bib_2") }
    let(:author_1) { FactoryGirl.create(:author, name: "author_1") }
    let(:author_2) { FactoryGirl.create(:author, name: "author_2") }
    before do
      bib_1.authors << author_1
      bib_2.authors << author_2
    end
    it { expect(subject).to start_with "Id,Name,Authors\n" }
    it { expect(subject).to include("#{bib_1.global_id},bib_1,author_1\n") }
    it { expect(subject).to include("#{bib_2.global_id},bib_2,author_2\n") }
  end

  describe "#pdf_files" do
    subject { bib.send(:pdf_files) }
    let(:bib) { FactoryGirl.build(:bib) }
    let(:attachment_file) { FactoryGirl.create(:attachment_file, data_content_type: data_content_type) }
    let(:data_content_type) { "application/pdf" }
    before do
      bib
      attachment_file
      allow(bib).to receive(:attachment_files).and_return(attachment_files)
    end
    context "attachment_files is nil" do
      let(:attachment_files) { nil }
      it { expect(subject).to be_nil }
    end
    context "attachment_files is blank" do
      let(:attachment_files) { [] }
      it { expect(subject).to be_nil }
    end
    context "attachment_files is present" do
      let(:attachment_files) { AttachmentFile.all }
      context "attachment_file type is pdf" do
        it { expect(subject).to eq [attachment_file] }
      end
      context "attachment_file type isn't pdf" do
        let(:data_content_type) { "image/jpeg" }
        it { expect(subject).to eq [] }
      end
    end
  end

end
