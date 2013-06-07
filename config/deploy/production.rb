set :domains, %w(predictionbook.com)
set :rails_env, 'production'
set :branch, "stable"

role :app, 'tofu.trikeapps.com'
role :web, 'tofu.trikeapps.com'
role :db,  'tofu.trikeapps.com', :primary => true

