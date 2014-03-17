require "spec_helper"

describe Bib do
  describe "constants" do
    describe "LABEL_HEADER" do
      subject { Bib::LABEL_HEADER }
      it { expect(subject).to eq ["Id","Name","Authors"] }
    end
  end
    
  describe "validates" do
    describe "name" do
      let(:bib) { FactoryGirl.build(:bib, name: name) }
      context "is presence" do
        let(:name) { "sample_bib_name" }
        it { expect(bib).to be_valid }
      end
      context "is blank" do
        let(:name) { "" }
        it { expect(bib).not_to be_valid }
      end
      describe "length" do
        context "is 255 characters" do
          let(:name) { "a" * 255 }
          it { expect(bib).to be_valid }
        end
        context "is 256 characters" do
          let(:name) { "a" * 256 }
          it { expect(bib).not_to be_valid }
        end
      end
    end
    describe "author" do
      context "is presence" do
        let(:bib) { FactoryGirl.build(:bib, authors: [author_1, author_2]) }
        let(:author_1) { FactoryGirl.create(:author, name: "name_1") }
        let(:author_2) { FactoryGirl.create(:author, name: "name_2") }
        it { expect(bib).to be_valid }
      end
      context "is blank" do
        let(:bib) { FactoryGirl.build(:bib, authors: []) }
        it { expect(bib).not_to be_valid }
      end
    end
  end

  describe ".doi_link_url" do
    subject { bib.doi_link_url }
    before { bib }
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
    let(:bib) { FactoryGirl.create(:bib, name: "foo", authors: [author_1, author_2]) }
    let(:author_1) { FactoryGirl.create(:author, name: "bar") }
    let(:author_2) { FactoryGirl.create(:author, name: "baz") }
    it { expect(subject).to eq "Id,Name,Authors\n#{bib.global_id},foo,bar baz\n" }
  end

  describe ".build_bundle_label" do
    subject { Bib.build_bundle_label(bibs) }
    let(:bibs) { Bib.all }
    let(:bib_1) { FactoryGirl.create(:bib, name: "bib_1", authors: [author_1]) }
    let(:bib_2) { FactoryGirl.create(:bib, name: "bib_2", authors: [author_2, author_3]) }
    let(:author_1) { FactoryGirl.create(:author, name: "author_1") }
    let(:author_2) { FactoryGirl.create(:author, name: "author_2") }
    let(:author_3) { FactoryGirl.create(:author, name: "author_3") }
    before do
      bib_1
      bib_2
    end
    it { expect(subject).to start_with "Id,Name,Authors\n" }
    it { expect(subject).to include("#{bib_1.global_id},bib_1,author_1\n") }
    it { expect(subject).to include("#{bib_2.global_id},bib_2,author_2 author_3\n") }
  end

  describe "#author_lists" do
    subject { bib.author_lists }
    let(:bib) { FactoryGirl.create(:bib, authors: [author_1, author_2]) }
    let(:author_1) { FactoryGirl.create(:author, name: "author_1") }
    let(:author_2) { FactoryGirl.create(:author, name: "author_2") }
    it { expect(subject).to eq "author_1 author_2" }
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
  
  describe ".build_bundle_tex" do
    subject { Bib.build_bundle_tex(bibs) }
    let(:bibs) { Bib.all }
    let(:bib_1) { FactoryGirl.create(:bib, name: "bib_1", authors: [author]) }
    let(:author) { FactoryGirl.create(:author, name: "name_1") }
    before { bib_1 }
    it { expect(subject).to eq "\n@misc{略１,\n\tauthor = \"name_1\",\n\tname = \"bib_1\",\n\tnumber = \"1\",\n\tmonth = \"january\",\n\tjournal = \"雑誌名１\",\n\tvolume = \"1\",\n\tpages = \"100\",\n\tyear = \"2014\",\n\tnote = \"注記１\",\n\tdoi = \"doi１\",\n\tkey = \"キー１\",\n}" }
  end
  
  describe "#to_tex" do
    subject { bib.to_tex }
    let(:bib) { FactoryGirl.create(:bib, entry_type: entry_type, abbreviation: abbreviation) }
    describe "@article" do
      before do
        bib
        allow(bib).to receive(:article_tex).and_return("test")
      end
      let(:entry_type) { "article" }
      context "abbreviation is not nil" do
        let(:abbreviation) { "abbreviation" }
        it { expect(subject).to eq "\n@article{abbreviation,\ntest,\n}" }
      end
      context "abbreviation is nil" do
        let(:abbreviation) { "" }
        it { expect(subject).to eq "\n@article{#{bib.global_id},\ntest,\n}" }
      end
    end
    describe "@misc" do
      before do
        bib
        allow(bib).to receive(:misc_tex).and_return("test")
      end
      let(:entry_type) { "entry_type" }
      context "abbreviation is not nil" do
        let(:abbreviation) { "abbreviation" }
        it { expect(subject).to eq "\n@misc{abbreviation,\ntest,\n}" }
      end
      context "abbreviation is nil" do
        let(:abbreviation) { "" }
        it { expect(subject).to eq "\n@misc{#{bib.global_id},\ntest,\n}" }
      end
    end
  end
  
  describe "#article_tex" do
    subject { bib.article_tex }
    let(:bib) do
      FactoryGirl.create(:bib,
        number: number,
        month: month,
        volume: volume,
        pages: pages,
        note: note,
        doi: doi,
        key: key,
        authors: [author]
       )
    end
    let(:author) { FactoryGirl.create(:author, name: "name_1") }
    context "value is nil" do
      let(:number) { "" }
      let(:month) { "" }
      let(:volume) { "" }
      let(:pages) { "" }
      let(:note) { "" }
      let(:doi) { "" }
      let(:key) { "" }
      it { expect(subject).to eq "\tauthor = \"name_1\",\n\tname = \"書誌情報１\",\n\tjournal = \"雑誌名１\",\n\tyear = \"2014\"" }
    end
    context "value is not nil" do
      let(:number) { "1" }
      let(:month) { "month" }
      let(:volume) { "1" }
      let(:pages) { "1" }
      let(:note) { "note" }
      let(:doi) { "doi" }
      let(:key) { "key" }
      it { expect(subject).to eq "\tauthor = \"name_1\",\n\tname = \"書誌情報１\",\n\tjournal = \"雑誌名１\",\n\tyear = \"2014\",\n\tnumber = \"1\",\n\tmonth = \"month\",\n\tvolume = \"1\",\n\tpages = \"1\",\n\tnote = \"note\",\n\tdoi = \"doi\",\n\tkey = \"key\"" }
    end
  end
  
  describe "#misc_tex" do
    subject { bib.misc_tex }
    let(:bib) do
      FactoryGirl.create(:bib,
        number: number,
        month: month,
        journal: journal,
        volume: volume,
        pages: pages,
        year: year,
        note: note,
        doi: doi,
        key: key,
        authors: [author]
       )
    end
    let(:author) { FactoryGirl.create(:author, name: "name_1") }
    context "value is nil" do
      let(:number) { "" }
      let(:month) { "" }
      let(:journal) { "" }
      let(:volume) { "" }
      let(:pages) { "" }
      let(:year) { "" }
      let(:note) { "" }
      let(:doi) { "" }
      let(:key) { "" }
      it { expect(subject).to eq "\tauthor = \"name_1\",\n\tname = \"書誌情報１\"" }
    end
    context "value is not nil" do
      let(:number) { "1" }
      let(:month) { "month" }
      let(:journal) { "journal" }
      let(:volume) { "1" }
      let(:pages) { "1" }
      let(:year) { "2014" }
      let(:note) { "note" }
      let(:doi) { "doi" }
      let(:key) { "key" }
      it { expect(subject).to eq "\tauthor = \"name_1\",\n\tname = \"書誌情報１\",\n\tnumber = \"1\",\n\tmonth = \"month\",\n\tjournal = \"journal\",\n\tvolume = \"1\",\n\tpages = \"1\",\n\tyear = \"2014\",\n\tnote = \"note\",\n\tdoi = \"doi\",\n\tkey = \"key\"" }
    end
  end
  
  describe "#author_valid?" do
    subject { bib.send(:author_valid?) }
    let(:bib) { FactoryGirl.build(:bib, authors: []) }
    it { expect(subject).to eq "can't be blank" }
  end

end
