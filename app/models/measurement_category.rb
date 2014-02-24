class MeasurementCategory < ActiveRecord::Base
  has_many :category_measurement_items
  has_many :measurement_items, through: :category_measurement_items
  belongs_to :unit

  validates :name, presence: true, length: {maximum: 255}

end
