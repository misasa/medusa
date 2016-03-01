require 'csv'

CSV.generate do |csv|
  csv << ["measured", "unit"] + @table.specimens.map(&:name) + ["mean", "1SD"]
  csv << ["igsn", ""] + @table.specimens.map(&:igsn) + ["", ""]

  if @table.with_place
    csv << ["latitude", ""] + @table.specimens.map{|specimen| specimen.place.try!(:latitude)} + ["", ""]
    csv << ["longitude", ""] + @table.specimens.map{|specimen| specimen.place.try!(:longitude)} + ["", ""]
  end
  csv << ["age", @table.age_unit] + @table.specimens.map{|specimen| specimen.age_in_text(:unit => @table.age_unit, :scale => @table.age_scale)} + ["", ""] if @table.with_age
  @table.each do |row|
    csv << [row.name, row.unit.try!(:text)] + row.map(&:value) + [row.mean, row.standard_diviation]
  end
end
