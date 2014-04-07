desc "classifications csv"
task :classifications_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT
        id,
        name,
        full_name,
        description,
        parent_id,
        lft,
        rgt
      FROM sample_classifications
      ORDER BY id
    )
    TO '/tmp/medusa_csv_files/classifications.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end