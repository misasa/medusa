desc "Execute backup of files and db."
task backup: ["backup:files", "backup:db"]

namespace :backup do

  desc "Execute backup of files by rsync command."
  task files: :environment do
    master = Rails.root
    current_name = Date.today.strftime("%Y%m%d")
    dir_path = Pathname.new(Settings.backup.files.dir_path)
    current = dir_path.join(current_name)

    FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)
    prev = dir_path.children.select { |dir| dir.basename.to_s < current_name }.max_by(&:basename)

    FileUtils.mkdir_p(current) unless Dir.exist?(current)

    command = "rsync -aL --delete --exclude=tmp/pids/*"
    command += " --link-dest=#{prev.relative_path_from(current)}/" if prev
    command += " #{master}/ #{current}/"

    Rails.logger.info command
    success = system command
    Rails.logger.info "File backup task is #{success ? "succeed" : "failed"}."
  end

  desc "Execute backup of database."
  task db: :environment do
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

  desc "Execute restore of database."
  task db_restore: :environment do
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
