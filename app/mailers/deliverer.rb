class Deliverer < ActionMailer::Base
  # helper :mailer
  
  # def deadline_notification(dn)
  #   standard_headers(dn)
  #   subject      "[PredictionBook] Judgement Day for ‘#{dn.description}’"
  #   body         :prediction => dn.prediction, :deadline => dn
  # end
  
  # def response_notification(rn)
  #   standard_headers(rn)
  #   subject      "[PredictionBook] There has been some activity on ‘#{rn.description}’"
  #   body         :prediction => rn.prediction, :notification => rn
  # end
  
  # private
  # def standard_headers(n)
  #   recipients   n.email_with_name
  #   from         %{"PredictionBook" <no-reply@#{default_url_options[:host]}>}
  #   reply_to     %{"PredictionBook" <no-reply@#{default_url_options[:host]}>}
  #   sent_on      Time.current
  # end
end
