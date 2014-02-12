desc "attachings csv"
task :attachings_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT
        id,
        attachment_id as attachment_file_id,
        attachable_id as attachable_id,
        CASE
          WHEN attachable_type = 'Storage' THEN 'Box'
          WHEN attachable_type = 'Specimen' THEN 'Stone'
          WHEN attachable_type = 'Abundance' THEN 'Analysis'
          ELSE ''
        END as attachable_type,
        position,
        created_at,
        updated_at
      FROM attachings
      ORDER BY id
     )
    TO '/tmp/csv/attachings.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY attachings
    FROM '/tmp/csv/attachings.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM attachings
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('attachings_id_seq', #{max_next_id})
  ")
  
end