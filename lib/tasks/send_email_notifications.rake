desc "Send email nofications of prediction deadlines"
task :send_email_notifications => :environment do
  DeadlineNotification.send_all!
  ResponseNotification.send_all!
end
