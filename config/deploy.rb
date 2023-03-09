set :repo_url,            'git@github.com:bellroy/predictionbook.git'
set :linked_dirs,         ['public/assets', 'log']
set :engine,              'passenger'
set :deploy_to,           -> { "/srv/www/#{fetch(:application)}" }
set :format,              :pretty
set :keep_releases,       5
set :application_label,   'PredictionBook'
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
set :slack_webhook_urls,  [ENV['SLACK_WEBHOOK_URL']].compact

namespace :deploy do
  before :starting, 'precheck:all'
  after :finished, :update_slack_message
  after :publishing, :restart
  after :cleanup, :tag
end
