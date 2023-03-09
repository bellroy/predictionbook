server 'kale-staging.trikeapps.com', user: 'predictionbook-staging', roles: [:app, :web, :db]

set :application,            'predictionbook-staging'
set :branch,                 -> { ENV.fetch('DEPLOY_BRANCH', 'master') }
set :rails_env,              'staging'
set :domain_name,            'staging.predictionbook.com'
set :conditionally_migrate,  false
set :assets_roles,           [:web, :app]
