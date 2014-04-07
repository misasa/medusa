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
    TO '/tmp/medusa_csv_files/attachment_files.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end