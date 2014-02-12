desc "box types csv"
task :box_types_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT 
        id,
        name,
        description
      FROM storage_types
      ORDER BY id
    )
    TO '/tmp/csv/box_types.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY box_types
    FROM '/tmp/csv/box_types.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM box_types
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('box_types_id_seq', #{max_next_id})
  ")
  
end