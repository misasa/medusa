namespace :db do

  desc "Execute database dump task."
  task dump: :environment do
    db_config = Rails.application.config.database_configuration[Rails.env]
    file_name = "#{Date.today.strftime("%Y%m%d")}.dump"
    dir_path = Pathname.new(Settings.backup.db.dir_path)
    file_path = dir_path.join(file_name)

    FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

    command = "pg_dump -U #{db_config["username"]} -w -Fc #{db_config["database"]} > #{file_path}"

    Rails.logger.info command
    success = system command
    Rails.logger.info "Database backup task is #{success ? "succeed" : "failed"}."
  end

  desc "Execute database restore task."
  task restore: :environment do
    db_config = Rails.application.config.database_configuration[Rails.env]
    file_name = "#{ENV["DUMP_DATE"]}.dump"
    dir_path = Pathname.new(Settings.backup.db.dir_path)
    file_path = dir_path.join(file_name)

    command = "pg_restore -U #{db_config["username"]} -w -Fc -d #{db_config["database"]} #{file_path}"

    Rails.logger.info command
    success = system command
    Rails.logger.info "Database restore task is #{success ? "succeed" : "failed"}."
  end

end
