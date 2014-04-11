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
    TO '/tmp/medusa_csv_files/abundances.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM devices
    )
    TO '/tmp/medusa_csv_files/devices.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM techniques
    )
    TO '/tmp/medusa_csv_files/techniques.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    DROP TABLE devices
  ")
  
  ActiveRecord::Base.connection.execute("
    DROP TABLE techniques
  ")
  
  abundances = CSV.table("/tmp/medusa_csv_files/abundances.csv")
  devices = CSV.table("/tmp/medusa_csv_files/devices.csv")
  techniques = CSV.table("/tmp/medusa_csv_files/techniques.csv")
  
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
  
  File.open("/tmp/medusa_csv_files/analyses.csv", "w") do |csv_file|
    csv_file.puts(add_column_to_abundance.to_csv)
  end
  
  FileUtils.rm("/tmp/medusa_csv_files/abundances.csv")
  
end