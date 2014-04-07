desc "tags csv"
task :tags_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT 
        id,
        name
      FROM tags
      ORDER BY id
    )
    TO '/tmp/medusa_csv_files/tags.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end