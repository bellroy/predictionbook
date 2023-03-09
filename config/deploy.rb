set :repo_url,            'git@github.com:bellroy/predictionbook.git'
set :linked_dirs,         ['public/assets', 'log']
set :engine,              'passenger'
set :deploy_to,           -> { "/srv/www/#{fetch(:application)}" }
set :format,              :pretty
set :keep_releases,       5
set :application_label,   'PredictionBook'
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
set :slack_webhook_urls,  [ENV['SLACK_WEBHOOK_URL']]

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
  after 'deploy:cleanup', 'deploy:tag'
end
