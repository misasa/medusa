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
    TO '/tmp/medusa_csv_files/box_types.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end