desc "groups csv"
task :groups_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT 
        id,
        name,
        created_at,
        updated_at
      FROM groups
      ORDER BY id
    )
    TO '/tmp/medusa_csv_files/groups.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end