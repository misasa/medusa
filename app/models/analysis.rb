class Analysis < ActiveRecord::Base
  include HasRecordProperty

  has_many :chemistries
  has_many :attachings, as: :attachable
  has_many :attachment_files, through: :attachings
  has_many :referrings, as: :referable
  has_many :bibs, through: :referrings
  belongs_to :stone

  validates :stone, existence: true
end
