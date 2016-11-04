module Quantity
  extend ActiveSupport::Concern

  UNITS = [:gram, :gramme, :grams, :grammes, :g]

  class << self
    def decimal_quantity(quantity, quantity_unit)
      quantity.try(quantity_unit).to_f.to_d
    end

    def string_quantity(quantity, quantity_unit)
      quantity.present? ? "#{quantity.to_s(:delimited)}(#{quantity_unit})" : ""
    end

    def unit_exists?(quantity_unit)
      num_and_unit = 1.try(quantity_unit)
      num_and_unit.class == Alchemist::Measurement && UNITS.include?(num_and_unit.unit_name)
    end
  end

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
end