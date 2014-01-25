class Place < ActiveRecord::Base
  include HasRecordProperty

  acts_as_mappable

  has_many :stones
  has_many :attachings, as: :attachable
  has_many :referrings, as: :referable
end
