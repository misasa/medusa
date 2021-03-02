class CustomAttribute < ApplicationRecord
  has_many :specimen_custom_attributes, dependent: :destroy
  has_many :specimens, through: :specimen_custom_attributes
  
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :sesar_name, length: { maximum: 255 }, uniqueness: true, allow_blank: true
end
