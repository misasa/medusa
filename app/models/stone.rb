class Stone < ActiveRecord::Base

  acts_as_taggable

  has_many :analyses
  has_many :children, class_name: "Stone", foreign_key: :parent_id
  has_many :attachings, as: :attachable
  has_many :referrings, as: :referable
  has_one :record_property, as: :datum
  belongs_to :parent, class_name: "Stone", foreign_key: :parent_id
  belongs_to :box
  belongs_to :place
  belongs_to :classification
  belongs_to :physical_form

  validates :box, existence: true
  validates :place, existence: true
  validates :classification, existence: true
  validates :physical_form, existence: true
end
