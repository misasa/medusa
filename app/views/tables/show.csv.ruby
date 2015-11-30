require 'csv'

CSV.generate do |csv|
  csv << ["measured", "unit"] + @table.specimens.map(&:name) + ["mean", "1SD"]
  @table.each do |row|
    csv << [row.name, row.unit.try!(:text)] + row.map(&:value) + [row.mean, row.standard_diviation]
  end
end
