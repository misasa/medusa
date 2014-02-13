desc "classifications csv"
task :classifications_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT
        id,
        name,
        full_name,
        description,
        parent_id,
        lft,
        rgt
      FROM sample_classifications
      ORDER BY id
    )
    TO '/tmp/csv/classifications.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY classifications
    FROM '/tmp/csv/classifications.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM classifications
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('classifications_id_seq', #{max_next_id})
  ")
  
end