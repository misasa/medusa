desc "record properties csv"
task :record_properties_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    ALTER TABLE data_properties 
    ADD owner_readable BOOLEAN,
    ADD owner_writable BOOLEAN,
    ADD group_readable BOOLEAN,
    ADD group_writable BOOLEAN,
    ADD guest_readable BOOLEAN,
    ADD guest_writable BOOLEAN,
    ADD name VARCHAR(255),
    ADD created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
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
          WHEN datum_type = 'Specimen' THEN 'Specimen'
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
        END as guest_readable,
        CASE
          WHEN o_permission = 0 THEN false
          WHEN o_permission = 4 THEN true
          WHEN o_permission = 6 THEN true
          ELSE false
        END as guest_writable,
        name,
        created_at,
        updated_at
      FROM data_properties
      ORDER BY id
     )
    TO '/tmp/medusa_csv_files/record_properties.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    ALTER TABLE data_properties
    DROP owner_readable,
    DROP owner_writable,
    DROP group_readable,
    DROP group_writable,
    DROP guest_readable,
    DROP guest_writable,
    DROP name,
    DROP created_at,
    DROP updated_at
  ")
  
end
