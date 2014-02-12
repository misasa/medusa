desc "record properties csv"
task :record_properties_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    ALTER TABLE data_properties 
    ADD owner_readable BOOLEAN,
    ADD owner_writable BOOLEAN,
    ADD group_readable BOOLEAN,
    ADD group_writable BOOLEAN,
    ADD gest_readable BOOLEAN,
    ADD gest_writable BOOLEAN
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT
        id,
        datum_id,
        CASE
          WHEN datum_type = 'AbundanceElement' THEN 'Chemistry'
          WHEN datum_type = 'Abundance' THEN 'Analysis'
          WHEN datum_type = 'PointOnImage' THEN 'Spot'
          WHEN datum_type = 'Locality' THEN 'Place'
          WHEN datum_type = 'Bibliography' THEN 'Bib'
          WHEN datum_type = 'Storage' THEN 'Box'
          WHEN datum_type = 'Attachment' THEN 'AttachmentFile'
          WHEN datum_type = 'Specimen' THEN 'Stone'
          ELSE ''
        END as datum_type,
        member_id as user_id,
        group_id,
        uniq_id as global_id,
        published,
        published_at,
        CASE
          WHEN m_permission = 0 THEN false
          WHEN m_permission = 2 THEN true
          WHEN m_permission = 6 THEN true
          ELSE false
        END as owner_readable,
        CASE
          WHEN m_permission = 0 THEN false
          WHEN m_permission = 4 THEN true
          WHEN m_permission = 6 THEN true
          ELSE false
        END as owner_writable,
        CASE
          WHEN g_permission = 0 THEN false
          WHEN g_permission = 2 THEN true
          WHEN g_permission = 6 THEN true
          ELSE false
        END as group_readable,
        CASE
          WHEN g_permission = 0 THEN false
          WHEN g_permission = 4 THEN true
          WHEN g_permission = 6 THEN true
          ELSE false
        END as group_writable,
        CASE
          WHEN o_permission = 0 THEN false
          WHEN o_permission = 2 THEN true
          WHEN o_permission = 6 THEN true
          ELSE false
        END as gest_readable,
        CASE
          WHEN o_permission = 0 THEN false
          WHEN o_permission = 4 THEN true
          WHEN o_permission = 6 THEN true
          ELSE false
        END as gest_writable
      FROM data_properties
      ORDER BY id
     )
    TO '/tmp/csv/record_properties.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    ALTER TABLE data_properties
    DROP owner_readable,
    DROP owner_writable,
    DROP group_readable,
    DROP group_writable,
    DROP gest_readable,
    DROP gest_writable
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY record_properties
    FROM '/tmp/csv/record_properties.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM record_properties
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('record_properties_id_seq', #{max_next_id})
  ")
  
end