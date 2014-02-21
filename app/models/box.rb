class Box < ActiveRecord::Base
  include HasRecordProperty

  acts_as_taggable
  with_recursive

  has_many :users
  has_many :stones
  has_many :children, class_name: "Box", foreign_key: :parent_id
  has_many :attachings, as: :attachable
  has_many :attachment_files, through: :attachings
  has_many :referrings, as: :referable
  has_many :bibs, through: :referrings
  belongs_to :parent, class_name: "Box", foreign_key: :parent_id
  belongs_to :box_type

  validates :box_type, existence: true, allow_nil: true
end
