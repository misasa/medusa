class Chemistry < ActiveRecord::Base
  include HasRecordProperty

  belongs_to :analysis
  belongs_to :measurement_item

  validates :analysis, existence: true
  validates :measurement_item, existence: true
end
