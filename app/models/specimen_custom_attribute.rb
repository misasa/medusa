class SpecimenCustomAttribute < ActiveRecord::Base
  belongs_to :specimen
  belongs_to :custom_attribute
  
  validates :value, length: { maximum: 255 }, uniqueness: { scope: [:specimen_id, :custom_attribute_id] }
end
