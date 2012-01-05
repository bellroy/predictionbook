class Deliverer < ActionMailer::Base
  # helper :mailer
  default :reply_to=> %{"PredictionBook" <no-reply@#{default_url_options[:host]}>},
          :from=>     %{"PredictionBook" <no-reply@#{default_url_options[:host]}>}

  def deadline_notification dn
    @prediction = dn.prediction
    @deadline = dn

    subject = "[PredictionBook] Judgement Day for ‘#{dn.description}’"
    mail(:subject=> subject, :to=> dn.email_with_name)
  end

  def response_notification rn
    @prediction = rn.prediction 
    @notification = rn
    subject = "[PredictionBook] There has been some activity on ‘#{rn.description}’"
    mail(:subject=> subject, :to=> rn.email_with_name)
  end
end
