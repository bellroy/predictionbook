set :domains, %w(predictionbook.com)
set :rails_env, 'production'
set :branch, "master"

role :app,    '' # Deploy to fresh instance and build AMI from this instance
role :web,    ''
role :db,     '', :primary => true

