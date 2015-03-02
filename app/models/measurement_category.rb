class MeasurementCategory < ActiveRecord::Base
  has_many :category_measurement_items, dependent: :destroy
  has_many :measurement_items, through: :category_measurement_items
  belongs_to :unit

  validates :name, presence: true, length: {maximum: 255}, uniqueness: :name
  validates :unit, existence: true, allow_nil: true

  def export_headers
    nicknames_with_unit.concat(nicknames.map { |nickname| "#{nickname}_error" })
  end

  def as_json(options = {})
    super({:methods => [:measurement_item_ids, :nicknames]}.merge(options))
  end

 # private
  def nicknames_with_unit
    return nicknames unless unit
    nicknames.map { |nickname| "#{nickname}_in_#{unit.name}" }
  end

  def nicknames
    measurement_items ? measurement_items.pluck(:nickname) : []
  end

end
