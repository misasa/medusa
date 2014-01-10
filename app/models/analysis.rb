class Analysis < ActiveRecord::Base
  has_many :chemistries
  has_many :attachings, as: :attachable
  has_many :referrings, as: :referable
  has_one :record_property, as: :datum
  belongs_to :stone

  validates :stone, existence: true
end
