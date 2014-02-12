desc "attachment files csv"
task :attachment_files_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT 
        id,
        title as name,
        body as description,
        md5hash,
        data_file_name,
        data_content_type,
        data_file_size,
        data_updated_at,
        original_geometry,
        affine_matrix,
        created_at,
        updated_at
      FROM attachments
    )
    TO '/tmp/csv/attachment_files.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY attachment_files
    FROM '/tmp/csv/attachment_files.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM attachment_files
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('attachment_files_id_seq', #{max_next_id})
  ")
  
end