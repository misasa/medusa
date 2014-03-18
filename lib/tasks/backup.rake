desc "Execute backup of files and db."
task backup: ["backup:files", "db:dump"]

namespace :backup do

  desc "Execute backup of files by rsync command."
  task files: :environment do
    master = Rails.root
    current_name = Date.today.strftime("%Y%m%d")
    dir_path = Pathname.new(Backup.dir_path.files)
    current = dir_path.join(current_name)

    dirs = `ssh #{Backup.ssh_host} ls #{dir_path}`.split("\n")
    prev = dirs.select { |dir| dir < current_name }.max
    prev = dir_path.join(prev)

    FileUtils.mkdir_p(current) unless Dir.exist?(current)

    command = "rsync -aL -e ssh --delete --exclude=tmp/pids/*"
    command += " --link-dest=#{prev.relative_path_from(current)}/" if prev
    command += " #{master}/ #{Backup.ssh_host}:#{current}/"

    Rails.logger.info command
    success = system command
    Rails.logger.info "File backup task is #{success ? "succeed" : "failed"}."
  end

end
