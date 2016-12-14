module Quantity
  UNITS = [:gram, :gramme, :grams, :grammes, :g]
  DEFAULT_UNIT = :g
  PREFIXES = Alchemist.library.unit_prefixes.each_with_object({}) do |(prefix, value), hash|
    exponent = Math.log10(value)
    hash[exponent] = prefix if exponent % 3 == 0 && prefix.length == 1
  end

  class << self
    def quantity(decimal_quantity)
      "#{decimal_quantity}E#{exponent(decimal_quantity) * -1}".to_f
    end

    def quantity_unit(decimal_quantity)
      "#{PREFIXES[exponent(decimal_quantity)]}#{DEFAULT_UNIT}"
    end

    def exponent(decimal_quantity)
      origin_exponent = decimal_quantity.exponent - (decimal_quantity.zero? ? 0 : 1)
      exponent = (origin_exponent - origin_exponent % 3).to_f
      exponent_max = PREFIXES.keys.max
      exponent_min = PREFIXES.keys.min
      if exponent > exponent_max
        exponent_max
      elsif exponent < exponent_min
        exponent_min
      else
        exponent
      end
    end

    def decimal_quantity(quantity, quantity_unit)
      quantity.try(quantity_unit.to_s).to_f.to_d
    end

    def string_quantity(quantity, quantity_unit)
      quantity.present? ? "#{quantity.to_s(:delimited)} #{quantity_unit}" : ""
    end

    def unit_exists?(quantity_unit)
      num_and_unit = 1.try(quantity_unit.to_s)
      num_and_unit.class == Alchemist::Measurement && UNITS.include?(num_and_unit.unit_name)
    end
  end
end