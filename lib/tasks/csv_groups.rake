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
    TO '/tmp/csv/groups.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY groups
    FROM '/tmp/csv/groups.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM groups
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('groups_id_seq', #{max_next_id})
  ")
  
end