desc "measurement items"
task :measurement_items_csv => :environment do
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
    TO '/tmp/csv/units_1.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM item_measureds
    )
    TO '/tmp/csv/item_measureds.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    DROP TABLE units
  ")
  
  item_measureds = CSV.table("/tmp/csv/item_measureds.csv")
  units = CSV.table("/tmp/csv/units_1.csv")
  
  units_hash = units.each_with_object({}) do |unit, hash|
    hash[unit[:name]] = unit[:id]
  end
  
  add_unit_id_measurement_items = item_measureds.each do |row|
    row << {
      item_code_1: row[:item_code],
      item_comment_1: row[:item_comment],
      item_html_1: row[:item_html],
      item_tex_1: row[:item_tex],
      unit_1: row[:unit]
    }
    row.delete(:item_code)
    row.delete(:item_description)
    row.delete(:item_comment)
    row.delete(:item_html)
    row.delete(:item_tex)
    row.delete(:unit)
    row << {
      nickname: row[:item_code_1],
      description: row[:item_comment_1],
      display_in_html: row[:item_html_1],
      display_in_tex: row[:item_tex_1],
      unit_id: units_hash[row[:unit_1]]
    }
    row.delete(:item_code_1)
    row.delete(:item_description_1)
    row.delete(:item_comment_1)
    row.delete(:item_html_1)
    row.delete(:item_tex_1)
    row.delete(:unit_1)
  end
  
  File.open("/tmp/csv/measurement_items.csv", "w") do |csv_file|
    csv_file.puts(add_unit_id_measurement_items.to_csv)
  end
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY measurement_items
    FROM '/tmp/csv/measurement_items.csv'
    WITH CSV HEADER
  ")
  
  max_next_chemistrie_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM measurement_items
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('measurement_items_id_seq', #{max_next_chemistrie_id})
  ")
  
  FileUtils.rm("/tmp/csv/item_measureds.csv")
  FileUtils.rm("/tmp/csv/units_1.csv")
  
end