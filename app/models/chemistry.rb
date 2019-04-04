class Chemistry < ActiveRecord::Base
  include HasRecordProperty

  belongs_to :analysis, touch: true
  belongs_to :measurement_item
  belongs_to :unit
  delegate :specimen, to: :analysis

  # avoid failure, when analysis import from csv.
  validates :analysis, existence: true, unless: -> { analysis && analysis.new_record? }
  validates :measurement_item, existence: true
  validates :unit, existence: true
  validates :value, numericality: true
  validates :uncertainty, numericality: true, allow_nil: true

  scope :with_measurement_item, -> { joins(:measurement_item) }
  scope :with_unit, -> { joins(:unit) }
  scope :search_with_measurement_item_id, ->(item_id) { where(measurement_item_id: item_id) }

  scope :add_select_field, lambda {|*fields|
    scope = current_scope || relation
    scope = scope.select(Arel.star) if scope.select_values.blank?
    scope.select(*fields)
  }

  scope :select_value_in_parts, lambda {
    add_select_field("#{value_in_parts_eq} as value_in_parts")
  }

  scope :select_summary_value_in_parts, lambda {
    select("count(#{value_in_parts_eq}) as count, max(#{value_in_parts_eq}) as max, min(#{value_in_parts_eq}) as min, avg(#{value_in_parts_eq}) as avg")
  }
  def self.value_in_parts_eq
    'value / units.conversion'
  end

  def display_name
    "#{measurement_item.display_name}: #{sprintf("%.2f", self.value)}"
  end

  def unit_conversion_value(unit_name, scale = nil)
    val = unit.present? ? Alchemist.measure(value, unit.name.to_sym) : Alchemist.measure(value, :g)
    val = val.to(unit_name.to_sym).value
    val = val.round(scale) if scale
    val
  end

  def to_pmlame
    {
      "#{measurement_item.nickname}" => measured_value,
      "#{measurement_item.nickname}_error" => measured_uncertainty,
     }
  end

  def measured_value
    unit ? Alchemist.measure(value, unit.name.to_sym).to(:parts).to_f : value
  end

  def measured_uncertainty
    (unit && uncertainty) ? Alchemist.measure(uncertainty, unit.name.to_sym).to(:parts).to_f : uncertainty
  end

end
