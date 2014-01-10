class Chemistry < ActiveRecord::Base
  belongs_to :analysis
  belongs_to :measurement_item
  has_one :record_property, as: :datum

  validates :analysis, existence: true
  validates :measurement_item, existence: true
end
