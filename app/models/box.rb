class Box < ActiveRecord::Base
  has_many :users
  has_many :stones
  has_many :children, class_name: "Box", foreign_key: :parent_id
  has_many :attachings, as: :attachable
  has_many :referrings, as: :referable
  has_one :record_property, as: :datum
  belongs_to :parent, class_name: "Box", foreign_key: :parent_id
  belongs_to :box_type

  validates :box_type, existence: true
end
