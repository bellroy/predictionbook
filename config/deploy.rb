trikelibs = Dir['config/cap-tasks/*.rb'].reject{ |file| file =~ /(radiant|aws)/ }
trikelibs.each { |trikelib| load(trikelib)  }

stages_glob = File.join(File.dirname(__FILE__), "deploy", "*.rb")
stages = Dir[stages_glob].collect { |f| File.basename(f, ".rb") }.sort
set :stages, stages
set :default_stage, 'staging'
require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :application, "predictionbook"
# This must be passed as a block, since rails_env is defined in the individual
# stages later.
set(:user) { "#{application}-#{rails_env}" }

set :scm, "git"
set :repository, "git@git.trikeapps.com:predictionbook.git"
set :repository_cache, 'cached-copy'
set :git_enable_submodules, 1
set :deploy_via, :remote_cache
set :bundle_without, [:development, :test, :cucumber, :darwin, :linux]

set :engine, "passenger"

# Secrets
set :secrets_repository, "git@git.trikeapps.com:settings/predictionbook.git"

# This must be passed as a block, since rails_env is defined in the individual
# stages later.
set(:deploy_to) { "/srv/www/#{application}-#{rails_env}" }

ssh_options[:forward_agent] = true

after "deploy:update_code", "bluepill:stop",
                            "secrets:update_configs",
                            "deploy:symlink_remote_db_yaml",
                            "deploy:symlink_remote_config_yamls"

after "deploy:symlink",     "bluepill:start"

namespace :deploy do
  desc 'Link to a database.yml file stored on the server'
  task :symlink_remote_db_yaml, :roles => [:app, :db, :worker] do
    run "ln -sf #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  desc 'Symlink all remote config yaml files'
  task :symlink_remote_config_yamls, :roles => [:app, :worker] do
    %w[credentials].each do |filename|
      run "ln -sf #{shared_path}/config/#{filename}.yml #{release_path}/config/#{filename}.yml"
    end
  end
end

namespace :bluepill do
  [:start, :stop].each do |command|
    desc "#{command} bluepill"
    task command, :roles => [:app, :worker] do
      run "sudo /etc/init.d/bluepill #{command}"
    end
  end
end

