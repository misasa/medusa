desc "taggings csv"
task :taggings_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT
        id,
        tag_id,
        taggable_id,
        CASE
          WHEN taggable_type = 'Specimen' THEN 'Stone'
          WHEN taggable_type = 'Storage' THEN 'Box'
          ELSE ''
        END as taggable_type,
        created_at
      FROM taggings
      ORDER BY id
     )
    TO '/tmp/csv/taggings_test.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  taggings = CSV.table("/tmp/csv/taggings_test.csv")
  
  add_column_taggings = taggings.each do |row|
    row << {
      created_at_1: row[:created_at]
    }
    row.delete(:created_at)
    row << {
      tagger_id: nil,
      tagger_type: nil,
      context: nil,
      created_at: row[:created_at_1]
    }
    row.delete(:created_at_1)
  end
  
  File.open("/tmp/csv/taggings.csv", "w") do |csv_file|
    csv_file.puts(add_column_taggings.to_csv)
  end
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY taggings
    FROM '/tmp/csv/taggings.csv'
    WITH CSV HEADER
  ")
  
  max_next_tagging_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM taggings
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('taggings_id_seq', #{max_next_tagging_id})
  ")
  
  FileUtils.rm("/tmp/csv/taggings_test.csv")
  
end