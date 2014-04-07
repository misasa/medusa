desc "measurement categories"
task :measurement_categories_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    CREATE TABLE units(
      id serial PRIMARY KEY,
      name VARCHAR(255),
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      conversion integer,
      html VARCHAR(10),
      text VARCHAR(10)
    )
  ")
  
  ActiveRecord::Base.connection.execute("
    INSERT INTO units(name, created_at, updated_at, conversion, html, text)
      VALUES ('parts', '2014-03-24', '2014-03-24', '1', '', '')
           , ('parts_per_cent', '2014-03-24', '2014-03-24', '100', '&#37;', 'ppc')
           , ('parts_per_mille', '2014-03-24', '2014-03-24', '1000', '&#8240;', 'permil')
           , ('parts_per_myriad', '2014-03-24', '2014-03-24', '10000', '&#8241;', 'permyriad')
           , ('parts_per_milli', '2014-03-24', '2014-03-24', '1000000', 'ppm', 'ppm')
           , ('parts_per_billi', '2014-03-24', '2014-03-24', '1000000000', 'ppb', 'ppb')
           , ('gram_per_gram', '2014-03-24', '2014-03-24', '1', 'g/g', 'g/g')
           , ('centi_gram_per_gram', '2014-03-24', '2014-03-24', '100', 'cg/g', 'cg/g')
           , ('micro_gram_per_gram', '2014-03-24', '2014-03-24', '1000000', '&micro;g/g', 'ug/g')
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM units
    )
    TO '/tmp/medusa_csv_files/units_1.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM item_types
    )
    TO '/tmp/medusa_csv_files/item_types.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    DROP TABLE units
  ")
  
  item_types = CSV.table("/tmp/medusa_csv_files/item_types.csv")
  units = CSV.table("/tmp/medusa_csv_files/units_1.csv")
  
  units_hash = units.each_with_object({}) do |unit, hash|
    hash[unit[:name]] = unit[:id]
  end
  
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
  
  File.open("/tmp/medusa_csv_files/measurement_categories.csv", "w") do |csv_file|
    csv_file.puts(add_unit_id_measurement_categories.to_csv)
  end
  
  FileUtils.rm("/tmp/medusa_csv_files/item_types.csv")
  FileUtils.rm("/tmp/medusa_csv_files/units_1.csv")
  
end