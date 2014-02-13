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
    TO '/tmp/csv/tags.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY tags
    FROM '/tmp/csv/tags.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM tags
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('tags_id_seq', #{max_next_id})
  ")
  
end