desc "referrings csv"
task :referrings_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT
        id,
        bibliography_id as bib_id,
        referable_id,
        CASE
          WHEN referable_type = 'Abundance' THEN 'Analysis'
          WHEN referable_type = 'Storage' THEN 'Box'
          WHEN referable_type = 'Specimen' THEN 'Stone'
          ELSE ''
        END as referable_type,
        created_at,
        updated_at
      FROM referrings
      ORDER BY id
     )
    TO '/tmp/csv/referrings.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY referrings
    FROM '/tmp/csv/referrings.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM referrings
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('referrings_id_seq', #{max_next_id})
  ")
  
end