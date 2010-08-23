require 'capistrano/ext/multistage'
#require 'config/recipes/content'

set :application, "staging.isotope11.com"
set :user, "deploy"
set :use_sudo, false

set :repository,  "git@github.com:rclements/isotope_site.git"
set :deploy_to, "/home/deploy/rails/isotope11/staging/#{application}"

#SCM setup
set :scm, :git
set :scm_verbose, true
set :git_username, "rclements"
set :deploy_via, :remote_cache

set :rails_env, 'production'

set :stages, %w(staging production)
set :default_stage, "staging"
set(:stage_path) { "#{latest_release}/config/stages/#{stage}" }


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

  after "deploy", "deploy:cleanup"

   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
