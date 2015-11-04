require 'csv'

CSV.generate do |csv|
  csv << ["measured", "unit"] + @table.stones.map(&:name) + ["avg", "std"]
  @table.each do |row|
    csv << [row.name, row.unit.try!(:text)] + row.map(&:value) + [row.mean, row.standard_diviation]
  end
end
