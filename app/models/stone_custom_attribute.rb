class StoneCustomAttribute < ActiveRecord::Base
  belongs_to :stone
  belongs_to :custom_attribute
  
  validates :value, length: { maximum: 255 }, uniqueness: { scope: [:stone_id, :custom_attribute_id] }
end
