class Chemistry < ActiveRecord::Base
  include HasRecordProperty

  belongs_to :analysis
  belongs_to :measurement_item
  belongs_to :unit
  delegate :specimen, to: :analysis

  validates :analysis, existence: true
  validates :measurement_item, existence: true
  validates :unit, existence: true
  validates :value, numericality: true
  validates :uncertainty, numericality: true, allow_nil: true

  def display_name
    "#{measurement_item.display_name}: #{sprintf("%.2f", self.value)}"
  end

  def unit_conversion_value(unit_name, scale = nil)
    val = unit.present? ? Alchemist.measure(value, unit.name.to_sym) : Alchemist.measure(value, :g)
    val = val.to(unit_name.to_sym).value
    val = val.round(scale) if scale
    val
  end
end
