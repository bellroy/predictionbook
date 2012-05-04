# encoding: utf-8

class Deliverer < ActionMailer::Base
  default :reply_to => Proc.new { no_reply },
          :from     => Proc.new { no_reply }

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

private

  def no_reply
    %{"PredictionBook" <no-reply@#{default_url_options[:host]}>}
  end
end

