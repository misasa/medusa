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
          WHEN attachable_type = 'Locality' THEN 'Place'
          WHEN attachable_type = 'Bibliography' THEN 'Bib'
          WHEN attachable_type = 'HptExperiment' THEN 'HptExperiment'
          ELSE ''
        END as attachable_type,
        position,
        created_at,
        updated_at
      FROM attachings a1
      WHERE NOT EXISTS (
        SELECT *
        FROM attachings a2
        WHERE a1.attachment_id = a2.attachment_id
          AND a1.attachable_id = a2.attachable_id
          AND a1.attachable_type = a2.attachable_type
          AND a1.id > a2.id
       )
      AND a1.attachable_type != 'HptExperiment'
      ORDER BY id
     )
    TO '/tmp/medusa_csv_files/attachings.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end