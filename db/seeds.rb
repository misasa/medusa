work_dir = Pathname.new("/tmp/medusa_csv_files")
FileUtils.mkdir_p(work_dir)

csv_dir = Rails.root.join("db", "csvs")
array_csv = Pathname.glob(csv_dir.join("*.csv"))
FileUtils.cp(array_csv, work_dir)

Pathname.glob(work_dir.join("*.csv")) do |path|
  ActiveRecord::Base.connection.execute("COPY #{path.basename(".csv")} FROM '#{path}' WITH CSV HEADER")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM #{path.basename(".csv")}
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('#{path.basename(".csv")}_id_seq', #{max_next_id})
  ")
end

FileUtils.rm_r(work_dir)