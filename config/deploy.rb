# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'dream'
set :repo_url, 'git@devel.misasa.okayama-u.ac.jp:orochi/medusa.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'
# set :deploy_to, '/srv/medusa/'
set :deploy_to, '/srv/dream/'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}
set :linked_files, %w{config/application.yml config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system config/unicorn}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rails_env, fetch(:stage)

namespace :deploy do

  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  desc "Recompile assets"
  task :recompile_assets do
    invoke "deploy:assets:clobber"
    invoke "deploy:compile_assets"
  end

  namespace :assets do
    task :precompile do
      on roles(fetch(:assets_roles)) do
        within release_path do
          with rails_env: fetch(:rails_env), rails_relative_url_root: fetch(:relative_url_root, "/medusa") do
            execute :rake, "assets:precompile"
          end
        end
      end
    end
    task :clobber do
      on roles(fetch(:assets_roles)) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, "assets:clobber"
          end
        end
      end
    end
  end
end
