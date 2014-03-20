Alchemist.setup

if Unit.attribute_method?(:name) && Unit.attribute_method?(:conversion)
  Unit.pluck(:name, :conversion).each do |name, conversion|
    Alchemist.register(:mass, name.to_sym, 1.to_d / conversion)
  end
end
