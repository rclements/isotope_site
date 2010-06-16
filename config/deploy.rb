set :application, "isotope11.com"
set :user, "deployer"
set :use_sudo, false

set :repository,  "git@github.com:rclements/isotope_site.git"
set :deploy_to, "/var/www/#{application}"
set :scm, :subversion, :git
set :git_enable_submodules, 1
set :git_username, "rclements"

set :port, 3000
set :location, "localhost"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "127.0.0.1"                          # Your HTTP server, Apache/etc
#role :app, "127.0.0.1"                          # This may be the same as your `Web` server
#role :db,  "127.0.0.1", :primary => true # This is where Rails migrations will run
#role :db,  "127.0.0.1"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
 desc "Restart Application"
    task :restart, :roles => :app do
      run "touch #{current_path}/tmp/restart.txt"
    end

    desc "Make symlink for database.yml" 
    task :symlink_dbyaml do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
    end

    desc "Create empty database.yml in shared path" 
    task :create_dbyaml do
      run "mkdir -p #{shared_path}/config" 
      put '', "#{shared_path}/config/database.yml" 
    end

    desc "Make symlink for s3.yml" 
    task :symlink_s3yaml do
      run "ln -nfs #{shared_path}/config/s3.yml #{release_path}/config/s3.yml" 
    end

    desc "Create empty s3.yml in shared path" 
    task :create_s3yaml do
      run "mkdir -p #{shared_path}/config" 
      put '', "#{shared_path}/config/s3.yml" 
    end

    desc "Make symlink for billing_on_rails.yml" 
    task :symlink_billingyaml do
      run "ln -nfs #{shared_path}/config/billing_on_rails.yml #{release_path}/config/billing_on_rails.yml" 
    end

    desc "Create empty billing_on_rails.yml in shared path" 
    task :create_billingyaml do
      run "mkdir -p #{shared_path}/config" 
      put '', "#{shared_path}/config/billing_on_rails.yml" 
    end
  end

  after 'deploy:setup', 'deploy:create_dbyaml'
  after 'deploy:update_code', 'deploy:symlink_dbyaml'

  after 'deploy:setup', 'deploy:create_s3yaml'
  after 'deploy:update_code', 'deploy:symlink_s3yaml'

  after 'deploy:setup', 'deploy:create_billingyaml'
  after 'deploy:update_code', 'deploy:symlink_billingyaml'

  after "deploy", "deploy:cleanup"

#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
