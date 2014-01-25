class Bib < ActiveRecord::Base
  include HasRecordProperty

  has_many :attachings, as: :attachable
  has_many :referrings
end
