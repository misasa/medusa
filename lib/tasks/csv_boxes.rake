desc "boxes csv"
task :boxes_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT 
        id,
        name,
        parent_id,
        position,
        path,
        storage_type_id as box_type_id,
        created_at,
        updated_at
      FROM storages
      ORDER BY id
    )
    TO '/tmp/csv/boxes.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY boxes
    FROM '/tmp/csv/boxes.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM boxes
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('boxes_id_seq', #{max_next_id})
  ")
  
end