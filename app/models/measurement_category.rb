class MeasurementCategory < ApplicationRecord
  has_many :category_measurement_items, -> { order :position }, dependent: :destroy
  has_many :measurement_items, -> { order 'category_measurement_items.position' }, through: :category_measurement_items
  belongs_to :unit

  accepts_nested_attributes_for :category_measurement_items

  validates :name, presence: true, length: {maximum: 255}, uniqueness: :name
  validates :unit, presence: { message: :required, if: -> { unit_id.present? } }

  def export_headers
    nicknames_with_unit.concat(nicknames.map { |nickname| "#{nickname}_error" })
  end

  def as_json(options = {})
    super({:methods => [:unit_name, :measurement_item_ids, :nicknames]}.merge(options))
  end

 # private
  def nicknames_with_unit
    return nicknames unless unit
    nicknames.map { |nickname| "#{nickname}_in_#{unit.name}" }
  end

  def nicknames
    measurement_items ? measurement_items.pluck(:nickname) : []
  end

  def unit_name
    unit.name if unit
  end
end
