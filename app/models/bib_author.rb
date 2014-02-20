class BibAuthor < ActiveRecord::Base
  belongs_to :bib
  belongs_to :author

  validates :bib, existence: true
  validates :author, existence: true
end
