# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

env :PATH, "/usr/local/bin:/usr/bin:/bin"

job_type :bundled_rake, "cd :path && RAILS_ENV=:environment chronic bundle exec rake :task --silent 2>&1 :output | ts"

if environment == "production"
  every 1.hour do
    bundled_rake "send_email_notifications"
  end
end

