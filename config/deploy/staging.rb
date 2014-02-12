set :domains, %w(staging.predictionbook.trikeapps.com)
set :rails_env, 'staging'
set :branch, "master"

role :app,    '10.0.3.100'
role :web,    '10.0.3.100'
role :db,     '10.0.3.100', :primary => true

