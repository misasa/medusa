class Bib < ActiveRecord::Base
  include HasRecordProperty

  has_many :attachings, as: :attachable
  has_many :attachment_files, through: :attachings
  has_many :referrings
  has_many :referable, through: :referrings
end
