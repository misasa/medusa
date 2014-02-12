desc "group members csv"
task :group_members_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    CREATE TABLE groups_members_test(
      id serial PRIMARY KEY,
      group_id INT,
      user_id INT
    )
  ")
  
  ActiveRecord::Base.connection.execute("
    INSERT INTO groups_members_test(group_id, user_id)
    SELECT group_id, member_id
    FROM groups_members
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM groups_members_test
    )
    TO '/tmp/csv/group_members.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    DROP TABLE groups_members_test
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY group_members
    FROM '/tmp/csv/group_members.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM group_members
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('group_members_id_seq', #{max_next_id})
  ")
  
end