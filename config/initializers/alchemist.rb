Alchemist.setup

if Unit.attribute_method?(:name) && Unit.attribute_method?(:conversion)
  Unit.pluck(:name, :conversion).each do |name, conversion|
    Alchemist.register(:mass, name.to_sym, 1.to_d / conversion)
  end
end

Alchemist.register(:time, [:annum, :annums, :a], 1.year)
Alchemist.register(:time, [:kiloannum, :kiloannums, :Ka], 1000.year)
Alchemist.register(:time, [:megaannum, :megaannums, :Ma], (1000**2).year)
Alchemist.register(:time, [:gigaannum, :gigaannums, :Ga], (1000**3).year)
