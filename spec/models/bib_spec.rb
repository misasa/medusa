# -*- coding: utf-8 -*-
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
      it { expect(subject).to eq "https://doi.org/test" }
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
    it { expect(subject).to eq "Id,Name,Authors\n#{bib.global_id},foo,bar and baz\n" }
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
    it { expect(subject).to include("#{bib_2.global_id},bib_2,author_2 and author_3\n") }
  end

  describe "#author_lists" do
    subject { bib.author_lists }
    let(:bib) { FactoryGirl.create(:bib, authors: [author_1, author_2]) }
    let(:author_1) { FactoryGirl.create(:author, name: "author_1") }
    let(:author_2) { FactoryGirl.create(:author, name: "author_2") }
    it { expect(subject).to eq "author_1 and author_2" }
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
    it { expect(subject).to eq "\n@misc{#{bib_1.global_id},\n\tauthor = \"name_1\",\n\ttitle = \"bib_1\",\n\tnumber = \"1\",\n\tmonth = \"january\",\n\tjournal = \"雑誌名１\",\n\tvolume = \"1\",\n\tpages = \"100\",\n\tyear = \"2014\",\n\tnote = \"注記１\",\n\tdoi = \"doi１\",\n\tkey = \"キー１\",\n}" }
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
        it { expect(subject).to eq "\n@article{#{bib.global_id},\ntest,\n}" }
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
        it { expect(subject).to eq "\n@misc{#{bib.global_id},\ntest,\n}" }
      end
      context "abbreviation is nil" do
        let(:abbreviation) { "" }
        it { expect(subject).to eq "\n@misc{#{bib.global_id},\ntest,\n}" }
      end
    end
  end
  
  describe "#article_tex", :current => true do
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
        authors: authors
       )
    end
    let(:authors) { [author, author_1, author_2]}
    let(:author) { FactoryGirl.create(:author, name: "Kobayashi, K.") }
    let(:author_1) { FactoryGirl.create(:author, name: "Nakamura, E.") }
    let(:author_2) { FactoryGirl.create(:author, name: "Ota, T.") }

    context "value is nil" do
      let(:number) { "" }
      let(:month) { "" }
      let(:volume) { "" }
      let(:pages) { "" }
      let(:note) { "" }
      let(:doi) { "" }
      let(:key) { "" }
      it { expect(subject).to eq "\tauthor = \"#{authors.map{|author| author.name }.join(' and ')}\",\n\ttitle = \"書誌情報１\",\n\tjournal = \"雑誌名１\",\n\tyear = \"2014\"" }
    end
    context "value is not nil" do
      let(:number) { "1" }
      let(:month) { "month" }
      let(:volume) { "1" }
      let(:pages) { "1" }
      let(:note) { "note" }
      let(:doi) { "doi" }
      let(:key) { "key" }
      it { expect(subject).to eq "\tauthor = \"#{authors.map{|author| author.name }.join(' and ')}\",\n\ttitle = \"書誌情報１\",\n\tjournal = \"雑誌名１\",\n\tyear = \"2014\",\n\tnumber = \"1\",\n\tmonth = \"month\",\n\tvolume = \"1\",\n\tpages = \"1\",\n\tnote = \"note\",\n\tdoi = \"doi\",\n\tkey = \"key\"" }
    end

    context "journal is 'DREAM Digital Document'", :current => true do
      let(:bib) do
        FactoryGirl.create(:bib,
          journal: journal,
          number: number,
          month: month,
          volume: volume,
          pages: pages,
          note: note,
          doi: doi,
          key: key,
          authors: authors
         )
      end
      let(:journal) {"DREAM Digital Document"}
      let(:number) { "1" }
      let(:month) { "month" }
      let(:volume) { "1" }
      let(:pages) { "1" }
      let(:note) { "note" }
      let(:doi) { "doi" }
      let(:key) { "key" }
      it { expect(subject).to eq "\tauthor = \"#{authors.map{|author| author.name }.join(' and ')}\",\n\ttitle = \"書誌情報１\",\n\tjournal = {\\href{http://dream.misasa.okayama-u.ac.jp/?q=#{bib.global_id}}{DREAM Digital Document}},\n\tyear = \"2014\",\n\tnumber = \"1\",\n\tmonth = \"month\",\n\tvolume = \"1\",\n\tpages = \"1\",\n\tnote = \"note\",\n\tdoi = \"doi\",\n\tkey = \"key\"" }
    end
  end
  
  describe "#misc_tex", :current => true do
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
      it { expect(subject).to eq "\tauthor = \"name_1\",\n\ttitle = \"書誌情報１\"" }
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
      it { expect(subject).to eq "\tauthor = \"name_1\",\n\ttitle = \"書誌情報１\",\n\tnumber = \"1\",\n\tmonth = \"month\",\n\tjournal = \"journal\",\n\tvolume = \"1\",\n\tpages = \"1\",\n\tyear = \"2014\",\n\tnote = \"note\",\n\tdoi = \"doi\",\n\tkey = \"key\"" }
    end
  end

  
  describe "#to_html" do
    subject { bib.to_html }
    let(:bib) do
      FactoryGirl.create(:bib,
        name: "bib_name",
        journal: journal,
        volume: volume,
        pages: pages,
        year: year,
        authors: authors
       )
    end
    let(:journal) { "journal" }
    let(:volume) { "1" }
    let(:pages) { "100" }
    let(:year) { "2014" }
    let(:author_1) { FactoryGirl.create(:author, name: "author_1") }
    let(:author_2) { FactoryGirl.create(:author, name: "author_2") }
    let(:author_3) { FactoryGirl.create(:author, name: "author_3") }
    let(:author_4) { FactoryGirl.create(:author, name: "author_4") }
    context "1 author" do
      let(:authors){ [author_1] }
      it { expect(subject).to eq "author_1 (#{year}) bib_name, <i>#{journal}</i>, <b>#{volume}</b>, #{pages}." }
    end

    context "2 authors" do
      let(:authors){ [author_1, author_2] }
      it { expect(subject).to eq "author_1 (#{year}) bib_name, <i>#{journal}</i>, <b>#{volume}</b>, #{pages}." }
    end

    context "3 author" do
      let(:authors){ [author_1, author_2, author_3] }
      it { expect(subject).to eq "author_1 (#{year}) bib_name, <i>#{journal}</i>, <b>#{volume}</b>, #{pages}." }
    end

    context "4 author" do
      let(:authors){ [author_1, author_2, author_3, author_4] }
      it { expect(subject).to eq "author_1 (#{year}) bib_name, <i>#{journal}</i>, <b>#{volume}</b>, #{pages}." }
    end

  end

  describe "#author_valid?" do
    subject { bib.send(:author_valid?) }
    let(:bib) { FactoryGirl.build(:bib, authors: []) }
    it { expect(subject).to eq "can't be blank" }
  end

  describe "#all_specimens", :current => true do
    let(:bib) { FactoryGirl.create(:bib) }
    let(:table){ FactoryGirl.create(:table) }
    let(:specimen_1){ FactoryGirl.create(:specimen) }
    let(:specimen_2){ FactoryGirl.create(:specimen) }
    let(:specimen_3){ FactoryGirl.create(:specimen) }
    before do
      bib
      specimen_1;specimen_2;specimen_3;
      bib.specimens << specimen_1
      bib.specimens << specimen_2
      bib.tables << table
      table.specimens << specimen_3
      #bib.specimens << specimen_3
    end

    it { expect(bib.specimens).to match_array([specimen_1, specimen_2])}
    #it { expect(bib.all_specimens).to match_array([specimen_1, specimen_2, specimen_3])}

  end

  describe "#all_places", :current => true do
    let(:bib) { FactoryGirl.create(:bib) }
    let(:place_1){ FactoryGirl.create(:place) }
    let(:place_2){ FactoryGirl.create(:place) }
    let(:place_3){ FactoryGirl.create(:place) }
    let(:place_4){ FactoryGirl.create(:place) }
    let(:specimen_1){ FactoryGirl.create(:specimen, place_id: place_1.id) }
    let(:specimen_2){ FactoryGirl.create(:specimen, place_id: place_2.id) }
    let(:specimen_3){ FactoryGirl.create(:specimen)}
    before do
      bib
      place_1;place_2;place_3;place_4;
      specimen_1;specimen_2;specimen_3;
      bib.places << place_3
      bib.places << place_4
      #specimen_3.place = nil
      #specimen_3.save
      bib.specimens << specimen_1
      bib.specimens << specimen_2
      #bib.specimens << specimen_3
    end

    it { expect(bib.places).to match_array([place_3, place_4])}
    it { expect(bib.all_places).to match_array([place_1, place_2, place_3, place_4])}
  end

  describe "#specimen_places", :current => true do
    let(:bib) { FactoryGirl.create(:bib) }
    let(:place_1){ FactoryGirl.create(:place) }
    let(:place_2){ FactoryGirl.create(:place) }
    let(:place_3){ FactoryGirl.create(:place) }
    let(:place_4){ FactoryGirl.create(:place) }
    let(:specimen_1){ FactoryGirl.create(:specimen, place_id: place_1.id) }
    let(:specimen_2){ FactoryGirl.create(:specimen, place_id: place_2.id) }
    let(:specimen_3){ FactoryGirl.create(:specimen)}
    before do
      bib
      place_1;place_2;place_3;place_4;
      specimen_1;specimen_2;specimen_3;
      bib.places << place_3
      bib.places << place_4
      #specimen_3.place = nil
      #specimen_3.save
      bib.specimens << specimen_1
      bib.specimens << specimen_2
      #bib.specimens << specimen_3
    end

    it { expect(bib.places).to match_array([place_3, place_4])}
    it { expect(bib.specimen_places).to match_array([place_1, place_2])}
  end


  describe "#referrings_analyses" do
    let(:bib) { FactoryGirl.create(:bib) }

    let(:box_1){ FactoryGirl.create(:box)}
    let(:place_1){ FactoryGirl.create(:place)}
    let(:specimen_1) { FactoryGirl.create(:specimen, name: "hoge", box_id: box_1.id) }
    let(:specimen_2) { FactoryGirl.create(:specimen, name: "specimen_2", place_id: place_1.id) }
    let(:specimen_3) { FactoryGirl.create(:specimen, name: "specimen_3", box_id: box_1.id) }
    let(:specimen_4) { FactoryGirl.create(:specimen, name: "specimen_3") }
    let(:analysis_1) { FactoryGirl.create(:analysis, specimen_id: specimen_1.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, specimen_id: specimen_2.id) }
    let(:analysis_3) { FactoryGirl.create(:analysis, specimen_id: specimen_3.id) }
    let(:analysis_4) { FactoryGirl.create(:analysis) }

    before do
      bib
      box_1;place_1;
      specimen_1;specimen_2;specimen_3;specimen_4;
      analysis_1;analysis_2;analysis_3;analysis_4;
      bib.boxes << box_1
      bib.places << place_1      
      bib.specimens << specimen_3
      bib.analyses << analysis_3      
      bib.analyses << analysis_4
    end
    it { expect(bib.analyses).to match_array([analysis_3, analysis_4])}
    it { expect(bib.referrings_analyses).to match_array([analysis_1, analysis_2, analysis_3, analysis_4])}
    it { expect(bib.to_pml).to include("\<global_id\>#{analysis_3.global_id}") }    
    it { expect(bib.to_pml).to include("\<global_id\>#{analysis_4.global_id}") }    
  end

  describe "#publish!", :current => true do
    subject { bib.publish! }
    let(:bib) { FactoryGirl.create(:bib) }

    let(:box_1){ FactoryGirl.create(:box)}
    let(:place_1){ FactoryGirl.create(:place)}
    let(:specimen_1) { FactoryGirl.create(:specimen, name: "hoge", box_id: box_1.id) }
    let(:specimen_2) { FactoryGirl.create(:specimen, name: "specimen_2", place_id: place_1.id) }
    let(:specimen_3) { FactoryGirl.create(:specimen, name: "specimen_3", box_id: box_1.id) }
    let(:specimen_4) { FactoryGirl.create(:specimen, name: "specimen_3") }
    let(:analysis_1) { FactoryGirl.create(:analysis, specimen_id: specimen_1.id) }
    let(:analysis_2) { FactoryGirl.create(:analysis, specimen_id: specimen_2.id) }
    let(:analysis_3) { FactoryGirl.create(:analysis, specimen_id: specimen_3.id) }
    let(:analysis_4) { FactoryGirl.create(:analysis) }

    before do
      bib
      box_1;place_1;
      specimen_1;specimen_2;specimen_3;specimen_4;
      analysis_1;analysis_2;analysis_3;analysis_4;
      bib.boxes << box_1
      bib.places << place_1
      allow(specimen_3).to receive(:publish!)
      bib.specimens << specimen_3
      allow(analysis_3).to receive(:publish!)
      allow(analysis_4).to receive(:publish!)
      bib.analyses << analysis_3     
      bib.analyses << analysis_4
    end

    it { expect{ subject }.not_to raise_error }
    it { expect{ subject }.to change{bib.published}.from(be_falsey).to(be_truthy) }
    it { expect{ subject }.to change{box_1.published}.from(be_falsey).to(be_truthy) }
    it { expect{ subject }.to change{place_1.published}.from(be_falsey).to(be_truthy) }
#    it { expect{ subject }.to change{specimen_3.published}.from(be_falsey).to(be_truthy) }
#    it { expect{ subject }.to change{analysis_3.published}.from(be_falsey).to(be_truthy) }
#    it { expect{ subject }.to change{analysis_4.published}.from(be_falsey).to(be_truthy) }


  end

end
