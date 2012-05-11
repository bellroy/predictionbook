# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

if environment == "production"
  every 5.minutes do
    rake "send_email_notifications"
  end
end

