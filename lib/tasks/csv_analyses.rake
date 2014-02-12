desc "analyses csv"
task :analyses_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    CREATE TABLE devices(
      id serial PRIMARY KEY,
      name VARCHAR(255),
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  ActiveRecord::Base.connection.execute("
    CREATE TABLE techniques(
      id serial PRIMARY KEY,
      name VARCHAR(255),
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  ActiveRecord::Base.connection.execute("
    INSERT INTO devices(name)
    SELECT DISTINCT instrument
    FROM abundances
    WHERE instrument IS NOT NULL
    AND instrument !=''
  ")
  
  ActiveRecord::Base.connection.execute("
    INSERT INTO techniques(name)
    SELECT DISTINCT technique
    FROM abundances
    WHERE technique IS NOT NULL
    AND technique !=''
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM abundances
    )
    TO '/tmp/csv/abundances.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM devices
    )
    TO '/tmp/csv/devices.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM techniques
    )
    TO '/tmp/csv/techniques.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    DROP TABLE devices
  ")
  
  ActiveRecord::Base.connection.execute("
    DROP TABLE techniques
  ")
  
  abundances = CSV.table("/tmp/csv/abundances.csv")
  devices = CSV.table("/tmp/csv/devices.csv")
  techniques = CSV.table("/tmp/csv/techniques.csv")
  
  devices_hash = devices.each_with_object({}) do |device, hash|
    hash[device[:name]] = device[:id]
  end
  
  techniques_hash = techniques.each_with_object({}) do |technique, hash|
    hash[technique[:name]] = technique[:id]
  end
  
  add_column_to_abundance = abundances.each do |row|
    row << {
      specimen_id_1: row[:specimen_id],
      analyst_1: row[:analyst],
      created_at_1: row[:created_at],
      updated_at_1: row[:updated_at],
      technique_1: row[:technique],
      instrument_1: row[:instrument]
    }
    row.delete(:specimen_id)
    row.delete(:analyst)
    row.delete(:created_at)
    row.delete(:updated_at)
    row.delete(:spot_id)
    row.delete(:technique)
    row.delete(:instrument)
    row.delete(:analysed_at)
    row << {
      stone_id: row[:specimen_id_1],
      operator: row[:analyst_1],
      created_at: row[:created_at_1],
      updated_at: row[:updated_at_1],
      technique_id: techniques_hash[row[:technique_1]],
      device_id: devices_hash[row[:instrument_1]]
    }
    row.delete(:specimen_id_1)
    row.delete(:analyst_1)
    row.delete(:created_at_1)
    row.delete(:updated_at_1)
    row.delete(:technique_1)
    row.delete(:instrument_1)
  end
  
  File.open("/tmp/csv/analyses.csv", "w") do |csv_file|
    csv_file.puts(add_column_to_abundance.to_csv)
  end
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY analyses
    FROM '/tmp/csv/analyses.csv'
    WITH CSV HEADER
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY devices
    FROM '/tmp/csv/devices.csv'
    WITH CSV HEADER
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY techniques
    FROM '/tmp/csv/techniques.csv'
    WITH CSV HEADER
  ")
  
  max_next_analyse_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM analyses
  ").to_i
  
  max_next_device_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM devices
  ").to_i
  
  max_next_technique_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM techniques
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('analyses_id_seq', #{max_next_analyse_id})
  ")
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('devices_id_seq', #{max_next_device_id})
  ")
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('techniques_id_seq', #{max_next_technique_id})
  ")
  
  FileUtils.rm("/tmp/csv/abundances.csv")
  
end