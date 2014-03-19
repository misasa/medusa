class Chemistry < ActiveRecord::Base
  include HasRecordProperty

  belongs_to :analysis
  belongs_to :measurement_item
  belongs_to :unit

  validates :analysis, existence: true
  validates :measurement_item, existence: true
  validates :unit, existence: true, allow_nil: true
  validates :value, numericality: true
  validates :uncertainty, numericality: true, allow_nil: true

  def display_name
    disp_name = measurement_item.display_in_html ? measurement_item.display_in_html : measurement_item.nickname
    "#{disp_name}: #{sprintf("%.2f", self.value)}"
  end
end
