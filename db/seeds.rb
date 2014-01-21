work_dir = Pathname.new("/tmp/medusa_csv_files")
FileUtils.mkdir_p(work_dir)

csv_dir = Rails.root.join("db", "csvs")
array_csv = Pathname.glob(csv_dir.join("*.csv"))
FileUtils.cp(array_csv, work_dir)

Pathname.glob(work_dir.join("*.csv")) do |path|
  ActiveRecord::Base.connection.execute("COPY #{path.basename(".csv")} FROM '#{path}' WITH CSV HEADER")
end

FileUtils.rm_r(work_dir)