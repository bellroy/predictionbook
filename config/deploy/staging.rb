server 'kale-staging.trikeapps.com', user: 'predictionbook-staging', roles: [:app, :web, :db]

set :application,            'predictionbook-staging'
set :branch,                 -> { ENV.fetch('DEPLOY_BRANCH', 'master') }
set :rails_env,              'staging'
set :domain_name,            'staging.predictionbook.com'
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
