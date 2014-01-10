class CategoryMeasurementItem < ActiveRecord::Base
  belongs_to :measurement_item
  belongs_to :measurement_category

  validates :measurement_item, existence: true
  validates :measurement_category, existence: true
end
