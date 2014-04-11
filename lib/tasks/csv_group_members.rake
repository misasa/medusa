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
    TO '/tmp/medusa_csv_files/group_members.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    DROP TABLE groups_members_test
  ")
  
end