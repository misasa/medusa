class Author < ActiveRecord::Base
  has_many :bib_authors
  has_many :bibs, through: :bib_authors

  validates :name, presence: true, length: { maximum: 255 }
end
