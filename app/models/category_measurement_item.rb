class CategoryMeasurementItem < ApplicationRecord
  belongs_to :measurement_item
  belongs_to :measurement_category
  belongs_to :unit
  acts_as_list scope: :measurement_category, column: :position

  validates :measurement_item, presence: true
  validates :measurement_category, presence: true

end
