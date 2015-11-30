desc "csv files data migrate"
task data_migrate: :environment do
  Rake::Task["db:migrate:reset"].invoke
  Rake::Task[:create_work_dir].invoke
  Rake::Task[:analyses_csv].invoke
  Rake::Task[:attachings_csv].invoke
  Rake::Task[:attachment_files_csv].invoke
  Rake::Task[:bib_authors_csv ].invoke
  Rake::Task[:bibs_csv].invoke
  Rake::Task[:box_types_csv].invoke
  Rake::Task[:boxes_csv].invoke
  Rake::Task[:category_measurement_items_csv].invoke
  Rake::Task[:chemistries_csv].invoke
  Rake::Task[:classifications_csv].invoke
  Rake::Task[:global_qrs_csv].invoke
  Rake::Task[:group_members_csv].invoke
  Rake::Task[:groups_csv].invoke
  Rake::Task[:measurement_categories_csv].invoke
  Rake::Task[:measurement_items_csv].invoke
  Rake::Task[:physical_forms_csv].invoke
  Rake::Task[:places_csv].invoke
  Rake::Task[:record_properties_csv].invoke
  Rake::Task[:referrings_csv].invoke
  Rake::Task[:spots_csv].invoke
  Rake::Task[:specimens_csv].invoke
  Rake::Task[:taggings_csv].invoke
  Rake::Task[:tags_csv].invoke
  Rake::Task[:units_csv].invoke
  Rake::Task[:users_csv].invoke
  ActiveRecord::Base.establish_connection Rails.env
  Rake::Task[:csv_data_moving].invoke
  Rake::Task["db:update_record_properties"].invoke
end
  
desc "create work directory"
task create_work_dir: :environment do
  work_dir = Pathname.new("/tmp/medusa_csv_files")
  FileUtils.rm_r(work_dir) if File.exist?(work_dir)
  FileUtils.mkdir_p(work_dir)
  File.chmod(0777, work_dir)
end
  
