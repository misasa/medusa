namespace :db do
  task :dump => [:environment]
  desc "Execute database load task."
  task load: :environment do
    db_config = Rails.application.config.database_configuration[Rails.env]
    file_path = "#{ENV["DUMP_PATH"]}"

    command = "psql -U #{db_config["username"]} #{db_config["database"]} < #{file_path}"

    Rails.logger.info command
    success = system command
    Rails.logger.info "Database load task is #{success ? "succeed" : "failed"}."
  end

  desc "Execute database dump task."
  task dump: :environment do
    db_config = Rails.application.config.database_configuration[Rails.env]
    file_name = "#{Date.today.strftime("%Y%m%d")}.dump"
    dir_path = Pathname.new(Backup.dir_path.db)
    file_path = dir_path.join(file_name)

    command = "pg_dump -U #{db_config["username"]} -w -Fc #{db_config["database"]} | ssh #{Backup.ssh_host} dd of=#{file_path}"

    Rails.logger.info command
    success = system command
    Rails.logger.info "Database backup task is #{success ? "succeed" : "failed"}."
  end

  desc "Execute database restore task."
  task restore: :environment do
    db_config = Rails.application.config.database_configuration[Rails.env]
    file_name = "#{ENV["DUMP_DATE"]}.dump"
    dir_path = Pathname.new(Backup.dir_path.db)
    file_path = dir_path.join(file_name)

    command = "pg_restore -U #{db_config["username"]} -w -Fc -d #{db_config["database"]} #{file_path}"

    Rails.logger.info command
    success = system command
    Rails.logger.info "Database restore task is #{success ? "succeed" : "failed"}."
  end

  desc "Execute database import task."
  task import: :environment do
    db_config = Rails.application.config.database_configuration[Rails.env]
    db_import = "#{ENV["DB_IMPORT"]}"
    command = "psql -U #{db_config["username"]} -h #{db_config["host"]} #{db_config["database"]} < #{db_import}"
    Rails.logger.info command
    success = system command
    Rails.logger.info "Database import task is #{success ? "succeed" : "failed"}."
  end

end
