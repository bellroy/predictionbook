set :domains, %w(staging.predictionbook.trikeapps.com)
set :rails_env, 'staging'
set :branch, "master"

role :app, 'tangelo-staging.trikeapps.com'
role :web, 'tangelo-staging.trikeapps.com'
role :db,  'tangelo-staging.trikeapps.com', :primary => true

