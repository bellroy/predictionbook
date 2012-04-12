set :domains, %w(staging.predictionbook.trikeapps.com)
set :rails_env, 'staging'
set :branch, "master"

role :app,    'staging.steak.trikeapps.com'
role :web,    'staging.steak.trikeapps.com'
role :db,     'staging.steak.trikeapps.com', :primary => true

