desc "chemistries csv"
task :chemistries_csv => :environment do
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
    TO '/tmp/csv/units.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM abundance_elements
    )
    TO '/tmp/csv/abundance_elements.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    DROP TABLE units
  ")
  
  abundance_elements = CSV.table("/tmp/csv/abundance_elements.csv")
  units = CSV.table("/tmp/csv/units.csv")
  
  units_hash = units.each_with_object({}) do |unit, hash|
    hash[unit[:name]] = unit[:id]
  end
  
  add_column_to_abundance_element = abundance_elements.each do |row|
    row << {
      abundance_id_1: row[:abundance_id],
      item_measured_id_1: row[:item_measured_id],
      info_1: row[:info],
      data_1: row[:data],
      label_1: row[:label],
      description_1: row[:description],
      error_1: row[:error],
      created_at_1: row[:created_at],
      updated_at_1: row[:updated_at]
     }
    row.delete(:abundance_id)
    row.delete(:item_measured_id)
    row.delete(:info)
    row.delete(:data)
    row.delete(:label)
    row.delete(:description)
    row.delete(:dated_at)
    row.delete(:error)
    row.delete(:created_at)
    row.delete(:updated_at)
    row << {
      analysis_id: row[:abundance_id_1],
      measurement_item_id: row[:item_measured_id_1],
      info: row[:info_1],
      value: row[:data_1],
      label: row[:label_1],
      description: row[:description_1],
      uncertainty: row[:error_1],
      created_at: row[:created_at_1],
      updated_at: row[:updated_at_1],
      unit_id: units_hash[row[:unit]]
     }
    row.delete(:abundance_id_1)
    row.delete(:item_measured_id_1)
    row.delete(:info_1)
    row.delete(:data_1)
    row.delete(:label_1)
    row.delete(:description_1)
    row.delete(:error_1)
    row.delete(:created_at_1)
    row.delete(:updated_at_1)
    row.delete(:unit)
  end
  
  File.open("/tmp/csv/chemistries.csv", "w") do |csv_file|
    csv_file.puts(add_column_to_abundance_element.to_csv)
  end
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY chemistries
    FROM '/tmp/csv/chemistries.csv'
    WITH CSV HEADER
  ")
  
  max_next_chemistrie_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM chemistries
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('chemistries_id_seq', #{max_next_chemistrie_id})
  ")
  
  FileUtils.rm("/tmp/csv/abundance_elements.csv")
  FileUtils.rm("/tmp/csv/units.csv")
  
end