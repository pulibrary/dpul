# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'pomegranate'
set :repo_url, 'https://github.com/pulibrary/pomegranate.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, '/opt/pomegranate'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/blacklight.yml', 'config/fedora.yml', 'config/config.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'vendor/bundle', 'public/uploads')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

namespace :sneakers do
  task :restart do
    on roles(:app) do
      execute :sudo, :initctl, :restart, "pom-sneakers"
    end
  end
end
namespace :sidekiq do
  task :quiet do
    on roles(:app) do
      # Horrible hack to get PID without having to use terrible PID files
      puts capture("kill -USR1 $(sudo initctl status pom-workers | grep /running | awk '{print $NF}') || :")
    end
  end
  task :restart do
    on roles(:app) do
      execute :sudo, :initctl, :restart, "pom-workers"
    end
  end
end
after 'deploy:reverted', 'sneakers:restart'
after 'deploy:published', 'sneakers:restart'
after 'deploy:starting', 'sidekiq:quiet'
after 'deploy:reverted', 'sidekiq:restart'
after 'deploy:published', 'sidekiq:restart'
