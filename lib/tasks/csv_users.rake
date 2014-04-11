desc "users csv"

task :users_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
  COPY(
    SELECT
      id,
      email,
      created_at,
      updated_at,
      administrator,
      family_name,
      given_name as first_name,
      remarks as description,
      login_name as username,
      storage_id as box_id
    FROM members
    ORDER BY id
  )
  TO '/tmp/medusa_csv_files/users_1.csv'
  (FORMAT 'csv', HEADER);
  ")
  
  users_1 = CSV.table("/tmp/medusa_csv_files/users_1.csv")
  
  users_csv_1 = users_1.each do |row|
    if row[:username] == "admin"
      row << { 
        email_1: "devel.misasa@gmail.com",
        created_at_1: row[:created_at],
        updated_at_1: row[:updated_at],
        administrator_1: row[:administrator],
        family_name_1: row[:family_name],
        first_name_1: row[:first_name],
        description_1: row[:description],
        username_1: row[:username],
        box_id_1: row[:box_id] 
       }
      row.delete(:email)
      row.delete(:created_at)
      row.delete(:updated_at)
      row.delete(:administrator)
      row.delete(:family_name)
      row.delete(:first_name)
      row.delete(:description)
      row.delete(:username)
      row.delete(:box_id)
      row << {
        email: row[:email_1],
        created_at: row[:created_at_1],
        updated_at: row[:updated_at_1],
        administrator: row[:administrator_1],
        family_name: row[:family_name_1],
        first_name: row[:first_name_1],
        description: row[:description_1],
        username: row[:username_1],
        box_id: row[:box_id_1] 
       }
      row.delete(:email_1)
      row.delete(:created_at_1)
      row.delete(:updated_at_1)
      row.delete(:administrator_1)
      row.delete(:family_name_1)
      row.delete(:first_name_1)
      row.delete(:description_1)
      row.delete(:username_1)
      row.delete(:box_id_1)
    end
  end
  
  File.open("/tmp/medusa_csv_files/users_2.csv", "w") do |csv_file|
    csv_file.puts(users_csv_1.to_csv)
  end
  
  users_csv_2 = CSV.table("/tmp/medusa_csv_files/users_2.csv")
  
  users_csv_3 = users_csv_2.each do |row|
    if row[:email] == ''
      row[:email] = nil
    end
  end
  
  File.open("/tmp/medusa_csv_files/users.csv", "w") do |csv_file|
    csv_file.puts(users_csv_3.to_csv)
  end
  
  FileUtils.rm("/tmp/medusa_csv_files/users_1.csv")
  FileUtils.rm("/tmp/medusa_csv_files/users_2.csv")
  
end