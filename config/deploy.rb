lock "~> 3.18.1"

server '213.226.127.175', roles: %w{app db web}

set :application, "ferma"
set :repo_url, "git@github.com:stap780/#{fetch(:application)}.git"


set :user, 'fermadep'

set :branch, "main"
set :pty,             true
set :stage,           :production
set :deploy_to,       "/var/www/#{fetch(:application)}"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
# set :puma_enable_socket_service, true

append :linked_files, "config/master.key", "config/database.yml", "config/sidekiq.yml"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "public", 'tmp/sockets', 'vendor/bundle', 'lib/tasks', 'lib/drop', 'storage'

namespace :puma do
    desc 'Create Directories for Puma Pids and Socket'
    task :make_dirs do
      on roles(:app) do
        execute "mkdir #{shared_path}/tmp/sockets -p"
        execute "mkdir #{shared_path}/tmp/pids -p"
      end
    end
  
    before 'deploy:starting', 'puma:make_dirs'
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      # Update this to your branch name: master, main, etc. Here it's master
      unless `git rev-parse HEAD` == `git rev-parse origin/main`
        puts "WARNING: HEAD is not the same as origin/main"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  
end
  
