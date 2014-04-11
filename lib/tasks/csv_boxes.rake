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
    TO '/tmp/medusa_csv_files/boxes.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end