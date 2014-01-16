class Referring < ActiveRecord::Base
  belongs_to :bib
  belongs_to :referable, polymorphic: true

  validates :bib, existence: true
end
