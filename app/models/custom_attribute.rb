class CustomAttribute < ActiveRecord::Base
  has_many :stone_custom_attributes, dependent: :destroy
  has_many :stones, through: :stone_custom_attributes
  
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :sesar_name, length: { maximum: 255 }, uniqueness: true
end
