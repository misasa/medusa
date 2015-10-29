class CategoryMeasurementItem < ActiveRecord::Base
  belongs_to :measurement_item
  belongs_to :measurement_category
  belongs_to :unit
  acts_as_list scope: :measurement_category, column: :position


  validates :measurement_item, existence: true
  validates :measurement_category, existence: true
  
  

end
