server ENV['STAGING_SERVER_HOSTNAME'], user: ENV['STAGING_SERVER_USERNAME'], roles: [:app, :web, :db]

set :application,            'predictionbook-staging'
set :branch,                 -> { ENV.fetch('DEPLOY_BRANCH', 'master') }
set :rails_env,              'staging'
set :domain_name,            'staging.predictionbook.com'
set :conditionally_migrate,  false
set :assets_roles,           [:web, :app]
