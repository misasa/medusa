namespace :backup do

  desc "Execute backup of files by rsync command."
  task files: :environment do
    master = Rails.root.join("public")
    current_name = Date.today.strftime("%Y%m%d")
    dir_path = Pathname.new(Settings.backup.files.dir_path)
    current = dir_path.join(current_name)
    prev = dir_path.children.select { |dir| dir.basename.to_s < current_name }.max_by(&:basename)

    FileUtils.mkdir_p(current) unless Dir.exist?(current)

    command = "rsync -a --delete"
    command += " --link-dest=#{prev.relative_path_from(current)}/" if prev
    command += " #{master}/ #{current}/"

    Rails.logger.info command
    success = system command
    Rails.logger.info "File backup task is #{success ? "succeed" : "failed"}."
  end

end
