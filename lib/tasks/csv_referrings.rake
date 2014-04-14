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
          WHEN referable_type = 'Locality' THEN 'Place'
          ELSE ''
        END as referable_type,
        created_at,
        updated_at
      FROM referrings r1
      WHERE NOT EXISTS (
        SELECT *
        FROM referrings r2
        WHERE r1.bibliography_id = r2.bibliography_id
          AND r1.referable_id = r2.referable_id
          AND r1.referable_type = r2.referable_type
          AND r1.id > r2.id
       )
      ORDER BY id
     )
    TO '/tmp/medusa_csv_files/referrings.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end