class Bib < ActiveRecord::Base
  has_many :attachings, as: :attachable
  has_many :referrings
  has_one :record_property, as: :datum
end
