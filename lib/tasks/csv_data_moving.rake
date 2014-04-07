desc "csv data moving"

task :csv_data_moving => :environment do
  work_dir = Pathname.new("/tmp/medusa_csv_files")
  Pathname.glob(work_dir.join("*.csv")) do |path|
    next if path.basename.to_s == "users.csv"
    ActiveRecord::Base.connection.execute("COPY #{path.basename(".csv")} FROM '#{path}' WITH CSV HEADER")
    
    max_next_id = ActiveRecord::Base.connection.select_value("
      SELECT MAX(id)
      FROM #{path.basename(".csv")}
    ").to_i
    
    ActiveRecord::Base.connection.execute("
      SELECT setval('#{path.basename(".csv")}_id_seq', #{max_next_id})
    ")
  end
  
  users = CSV.table("#{work_dir}/users.csv")
  
  users.each do |row|
    row << { password: "password", password_confirmation: "password" }
    User.create(row.to_h)
  end
  
  user_max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM users
  ").to_i
    
  ActiveRecord::Base.connection.execute("
    SELECT setval('users_id_seq', #{user_max_next_id})
  ")
end