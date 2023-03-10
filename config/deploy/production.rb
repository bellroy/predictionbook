server ENV['PRODUCTION_SERVER_HOSTNAME'], user: ENV['PRODUCTION_SERVER_USERNAME'], roles: [:app, :web, :db]

set :application,            'predictionbook-production'
set :branch,                 'stable'
set :rails_env,              'production'
set :domain_name,            'predictionbook.com'
set :conditionally_migrate,  false
set :assets_roles,           [:web, :app]
