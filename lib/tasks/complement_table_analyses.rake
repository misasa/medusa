desc "Delete invalid table_specimens records."
task delete_invalid_table_specimens: :environment do
  TableSpecimen.all.each do |table_specimen|
    table_specimen.destroy unless Table.exists?(id: table_specimen.table_id)
  end
end

desc "Delete invalid table_analyses records."
task delete_invalid_table_analyses: :delete_invalid_table_specimens do
  TableAnalysis.all.each do |table_analysis|
    table_analysis.destroy unless TableSpecimen.exists?(table_id: table_analysis.table_id, specimen_id: table_analysis.specimen_id)
  end
end

desc "Complement the lack of table_analyses records."
task complement_table_analyses: :delete_invalid_table_analyses do
  Table.includes(table_specimens: { specimen: :analyses }).each do |table|
    table.table_specimens.each do |table_specimen|
      table_specimen.specimen.analyses.each do |analysis|
        key = { table_id: table.id, specimen_id: table_specimen.specimen_id, analysis_id: analysis.id }
        next if TableAnalysis.exists?(name: key)
        priority = (table.table_analyses.where(specimen_id: table_specimen.specimen_id).maximum(:priority) || 0) + 1
        TableAnalysis.create!(key.merge(priority: priority))
      end
    end
  end
end
