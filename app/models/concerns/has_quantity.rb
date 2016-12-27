module HasQuantity
  extend ActiveSupport::Concern

  def decimal_quantity
    Quantity.decimal_quantity(quantity, quantity_unit)
  end

  def decimal_quantity_was
    Quantity.decimal_quantity(quantity_was, quantity_unit_was)
  end

  def string_quantity
    Quantity.string_quantity(quantity, quantity_unit)
  end

  def string_quantity_was
    Quantity.string_quantity(quantity_was, quantity_unit_was)
  end

  def quantity_with_unit
    return unless quantity
    "#{quantity} #{quantity_unit}"
  end

  def quantity_with_unit=(string)
    vals = string.split(/\s/)
    self.quantity = vals[0]
    self.quantity_unit = vals[1] if vals.size > 1
  end

  def quantity_unit_exists
    unless quantity_unit.blank? || Quantity.unit_exists?(quantity_unit)
      errors.add(:quantity_unit, "\"#{quantity_unit}\" does not exist")
    end
  end
end