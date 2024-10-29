# config valid for current version and patch releases of Capistrano
lock "~> 3.11.2"

set :application, "nyte_ticker"
set :repo_url, "git@github.com:viamin/stock-ticker-dashboard.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, "ruby27"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/nyte_ticker"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/master.key"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :migration_role, :app

set :assets_manifests, ['app/assets/config/manifest.js']

namespace :deploy do
  namespace :check do
    before :linked_files, :set_master_key do
      on roles(:app) do
        unless test("[ -f #{shared_path}/config/master.key ]")
          upload! 'config/master.key', "#{shared_path}/config/master.key"
        end
      end
    end
  end

  Rake::Task["deploy:assets:backup_manifest"].clear_actions
end

namespace :puma do
  desc 'Restart Puma'
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, 'puma'
      # Or if using a puma service with a different name:
      # execute :sudo, :systemctl, :restart, 'your-puma-service-name'
    end
  end
end

after 'deploy:finished', 'puma:restart'
