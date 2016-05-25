require 'cap-deploy-tagger/capistrano'
server 'tangelo.trikeapps.com', user: 'predictionbook-production', roles: [:app, :web, :db]
set :deploy_tag, Time.now.strftime('%Y%m%d%H%M')
set :application,            'predictionbook-production'
set :branch,                 'stable'
set :rails_env,              'production'
set :domain_name,            'predictionbook.com'
set :conditionally_migrate,  false
set :assets_roles,           [:web, :app]
set :symlinked_dot_files,    []

namespace :deploy do
  desc 'Creates a symlink for dot files in the root directory'
  task :symlink_dotfiles do
    on roles(:app) do
      fetch(:symlinked_dot_files).each do |file|
        execute "ln -sf #{shared_path}/config/#{file} #{release_path}/#{file}"
      end
    end
  end
end

before 'deploy:starting', 'secrets:update_configs'
after 'secrets:update_configs', 'deploy:symlink_dotfiles'
