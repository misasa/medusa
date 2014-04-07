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
    TO '/tmp/medusa_csv_files/taggings_test.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  taggings = CSV.table("/tmp/medusa_csv_files/taggings_test.csv")
  
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
  
  File.open("/tmp/medusa_csv_files/taggings.csv", "w") do |csv_file|
    csv_file.puts(add_column_taggings.to_csv)
  end
  
  FileUtils.rm("/tmp/medusa_csv_files/taggings_test.csv")
  
end