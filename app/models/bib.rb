class Bib < ActiveRecord::Base
  include HasRecordProperty

  has_many :bib_authors
  has_many :authors, through: :bib_authors

  has_many :attachings, as: :attachable
  has_many :attachment_files, through: :attachings
  has_many :referrings
  has_many :stones, through: :referrings, source: :referable, source_type: "Stone"
  has_many :places, through: :referrings, source: :referable, source_type: "Place"
  has_many :boxes, through: :referrings, source: :referable, source_type: "Box"
  has_many :analyses, through: :referrings, source: :referable, source_type: "Analysis"
  
  def doi_link_url
    return unless doi
    "http://dx.doi.org/#{doi}"
  end
  
end
