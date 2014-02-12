desc "global qrs csv"
task :global_qrs_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT 
        id,
        data_property_id as record_property_id,
        data_file_name as file_name,
        data_content_type as content_type,
        data_file_size as file_size,
        data_updated_at as file_updated_at,
        identifier
      FROM uniq_qrs
      ORDER BY id
    )
    TO '/tmp/csv/global_qrs.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY global_qrs
    FROM '/tmp/csv/global_qrs.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM global_qrs
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('global_qrs_id_seq', #{max_next_id})
  ")
  
end