class Analysis < ActiveRecord::Base
  include HasRecordProperty

  has_many :chemistries
  has_many :attachings, as: :attachable
  has_many :referrings, as: :referable
  belongs_to :stone

  validates :stone, existence: true
end
