class MeasurementItem < ActiveRecord::Base
  has_many :chemistries
  has_many :category_measurement_items
  has_many :measurement_categories, through: :category_measurement_items
  belongs_to :unit
end
