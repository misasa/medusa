desc "measurement categories"
task :measurement_categories_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    CREATE TABLE units(
      id serial PRIMARY KEY,
      name VARCHAR(255),
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  ActiveRecord::Base.connection.execute("
    INSERT INTO units(name)
    SELECT DISTINCT unit
    FROM abundance_elements
    WHERE unit IS NOT NULL
    AND unit !=''
    UNION
    SELECT DISTINCT unit
    FROM item_measureds
    WHERE unit IS NOT NULL
    AND unit !=''
    UNION
    SELECT DISTINCT unit
    FROM item_types
    WHERE unit IS NOT NULL
    AND unit !=''
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM units
    )
    TO '/tmp/csv/units.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM item_types
    )
    TO '/tmp/csv/item_types.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  item_types = CSV.table("/tmp/csv/item_types.csv")
  units = CSV.table("/tmp/csv/units.csv")
  
  units_hash = units.each_with_object({}) do |unit, hash|
    hash[unit[:name]] = unit[:id]
  end
  
  FileUtils.rm("/tmp/csv/item_types.csv")
  
  add_unit_id_measurement_categories = item_types.each do |row|
    row << {
      item_type_1: row[:item_type],
      item_type_desc_1: row[:item_type_desc],
      unit_1: row[:unit]
    }
    row.delete(:item_type)
    row.delete(:item_type_desc)
    row.delete(:unit)
    row << {
      name: row[:item_type_1],
      description: row[:item_type_desc_1],
      unit_id: units_hash[row[:unit_1]]
    }
    row.delete(:item_type_1)
    row.delete(:item_type_desc_1)
    row.delete(:unit_1)
  end
  
  File.open("/tmp/csv/measurement_categories.csv", "w") do |csv_file|
    csv_file.puts(add_unit_id_measurement_categories.to_csv)
  end
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY measurement_categories
    FROM '/tmp/csv/measurement_categories.csv'
    WITH CSV HEADER
  ")
  
  max_next_chemistrie_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM measurement_categories
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('measurement_categories_id_seq', #{max_next_chemistrie_id})
  ")
  
  FileUtils.rm("/tmp/csv/units.csv")
  
end