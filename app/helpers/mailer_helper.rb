module MailerHelper
  def prediction_link(notification)
    prediction_url(notification.prediction, :token => notification.uuid)
  end
end