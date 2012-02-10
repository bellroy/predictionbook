set :domains, %w(staging.predictionbook.trikeapps.com)
set :rails_env, 'staging'
set :branch, "master"

role :app,    'poppy.trikeapps.com'
role :web,    'poppy.trikeapps.com'
role :db,     'poppy.trikeapps.com', :primary => true
