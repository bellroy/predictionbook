set :repo_url,            'git@github.com:bellroy/predictionbook.git'
set :secrets_repository,  'git@git.trikeapps.com:settings/predictionbook.git'
set :linked_dirs,         ['public/assets', 'log']
set :symlinked_configs,   %w(database.yml credentials.yml)
set :engine,              'passenger'
set :deploy_to,           -> { "/srv/www/#{fetch(:application)}" }
set :format,              :pretty
set :keep_releases,       5
set :application_label,   'PredictionBook'
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do
  desc 'Create a symlink in the release path to all _symlinked_configs_'
  task :symlink_configs do
    on roles(:app) do
      fetch(:symlinked_configs).each do |file|
        execute "ln -sf #{shared_path}/config/#{file} #{release_path}/config/#{file}"
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
  after 'deploy:symlink:linked_dirs', :symlink_configs
  after 'deploy:cleanup', 'deploy:tag'
end
