namespace :thin do
  desc "Start Thin"
  task :start do
    sh "bundle exec thin start -C #{Rails.root}/config/thin.yml -c #{Rails.root}"
  end

  desc "Stop Thin"
  task :stop do
    sh "bundle exec thin stop -C #{Rails.root}/config/thin.yml"
  end
end