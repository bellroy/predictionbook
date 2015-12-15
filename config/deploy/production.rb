set :domains, %w(predictionbook.com)
set :rails_env, 'production'
set :branch, "stable"

role :app, 'tangelo.trikeapps.com'
role :web, 'tangelo.trikeapps.com'
role :db,  'tangelo.trikeapps.com', :primary => true

