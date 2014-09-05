class Bib < ActiveRecord::Base
  include HasRecordProperty
  include HasViewSpot
  include OutputPdf
  include HasAttachmentFile

  LABEL_HEADER = ["Id", "Name", "Authors"]

  has_many :bib_authors
  has_many :authors, through: :bib_authors

  has_many :referrings, dependent: :destroy
  has_many :stones, through: :referrings, source: :referable, source_type: "Stone"
  has_many :places, through: :referrings, source: :referable, source_type: "Place"
  has_many :boxes, through: :referrings, source: :referable, source_type: "Box"
  has_many :analyses, through: :referrings, source: :referable, source_type: "Analysis"
  
  validates :name, presence: true, length: { maximum: 255 }
  validate :author_valid?, if: Proc.new{|bib| bib.authors.blank?}
  
  def doi_link_url
    return unless doi
    "http://dx.doi.org/#{doi}"
  end
  
  def primary_pdf_attachment_file
    pdf_files.first if pdf_files.present?
  end

  def build_label
    CSV.generate do |csv|
      csv << LABEL_HEADER
      csv << ["#{global_id}", "#{name}", "#{author_lists}"]
    end
  end

  def self.build_bundle_label(bibs)
    CSV.generate do |csv|
      csv << LABEL_HEADER
      bibs.each do |bib|
        csv << ["#{bib.global_id}", "#{bib.name}", "#{bib.author_lists}"]
      end
    end
  end
  
  def self.build_bundle_tex(bibs)
    bibs.map{|bib| bib.to_tex}.join(" ")
  end
  
  def to_tex
    if entry_type == "article"
#      tex = "\n@article{#{abbreviation.presence || global_id},\n#{article_tex},\n}"
      tex = "\n@article{#{global_id},\n#{article_tex},\n}"
    else
#      tex = "\n@misc{#{abbreviation.presence || global_id},\n#{misc_tex},\n}"
      tex = "\n@misc{#{global_id},\n#{misc_tex},\n}"      
    end
    return tex
  end
  
  def article_tex
    bib_array = []
    bib_array << "\tauthor = \"#{author_lists}\""
    bib_array << "\ttitle = \"#{name}\""
    bib_array << "\tjournal = \"#{journal}\""
    bib_array << "\tyear = \"#{year}\""
    bib_array << "\tnumber = \"#{number}\"" if number.present?
    bib_array << "\tmonth = \"#{month}\"" if month.present?
    bib_array << "\tvolume = \"#{volume}\"" if volume.present?
    bib_array << "\tpages = \"#{pages}\"" if pages.present?
    bib_array << "\tnote = \"#{note}\"" if note.present?
    bib_array << "\tdoi = \"#{doi}\"" if doi.present?
    bib_array << "\tkey = \"#{key}\"" if key.present?
    bib_array.join(",\n")
  end
  
  def misc_tex
    bib_array = []
    bib_array << "\tauthor = \"#{author_lists}\""
    bib_array << "\ttitle = \"#{name}\""
    bib_array << "\tnumber = \"#{number}\"" if number.present?
    bib_array << "\tmonth = \"#{month}\"" if month.present?
    bib_array << "\tjournal = \"#{journal}\"" if journal.present?
    bib_array << "\tvolume = \"#{volume}\"" if volume.present?
    bib_array << "\tpages = \"#{pages}\"" if pages.present?
    bib_array << "\tyear = \"#{year}\"" if year.present?
    bib_array << "\tnote = \"#{note}\"" if note.present?
    bib_array << "\tdoi = \"#{doi}\"" if doi.present?
    bib_array << "\tkey = \"#{key}\"" if key.present?
    bib_array.join(",\n")
  end

  def author_lists
    authors.pluck(:name).join(" and ")
  end

  def to_html
    html = authors.first.name
    html += " (#{year})" if year.present?
    html += " #{name}" if name.present?
    html += ", <i>#{journal}</i>" if journal.present?
    html += ", <b>#{volume}</b>" if volume.present?
    html += ", #{pages}" if pages.present?
    return "#{html}."
  end

  private

  def pdf_files
    if attachment_files.present?
      attachment_files.order("updated_at desc").select {|file| file.pdf? }
    end
  end
  
  def author_valid?
    errors[:author] = "can't be blank"
  end
end
