set :application, "development.isotope11.com"
set :user, "robby"
set :use_sudo, false

set :repository,  "git@github.com:rclements/isotope_site.git"
set :deploy_to, "/var/www/#{application}"
set :scm, :git
set :git_enable_submodules, 1
set :git_username, "rclements"

#set :port, 3000
set :location, "localhost"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "localhost"                          # Your HTTP server, Apache/etc
role :app, "localhost"                          # This may be the same as your `Web` server
role :db,  "localhost", :primary => true # This is where Rails migrations will run
role :db,  "localhost"


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
  
    
  after 'deploy:setup', 'deploy:create_dbyaml'
  after 'deploy:update_code', 'deploy:symlink_dbyaml'

  after 'deploy:setup', 'deploy:create_s3yaml'
  after 'deploy:update_code', 'deploy:symlink_s3yaml'

  after 'deploy:setup', 'deploy:create_billingyaml'
  after 'deploy:update_code', 'deploy:symlink_billingyaml'

  after "deploy", "deploy:cleanup"

   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
end
