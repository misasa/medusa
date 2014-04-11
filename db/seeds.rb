Rake::Task[:create_work_dir].invoke

csv_dir = Rails.root.join("db", "csvs")
array_csv = Pathname.glob(csv_dir.join("*.csv"))
work_dir = Pathname.new("/tmp/medusa_csv_files")
FileUtils.cp(array_csv, work_dir)

Rake::Task[:csv_data_moving].invoke

FileUtils.rm_r(work_dir)