# encoding: utf-8

class Deliverer < ActionMailer::Base
  default reply_to: proc { no_reply },
          from: proc { no_reply }

  def deadline_notification(dn)
    @prediction = dn.prediction
    @deadline   = dn

    mail(
      subject: "[PredictionBook] Judgement Day for ‘#{dn.description}’",
      to: dn.email_with_name
    )
  end

  def response_notification(rn)
    @prediction   = rn.prediction
    @notification = rn

    mail(
      subject: "[PredictionBook] There has been some activity on ‘#{rn.description}’",
      to: rn.email_with_name
    )
  end

  private

  def no_reply
    %("PredictionBook" <no-reply@#{default_url_options[:host]}>)
  end
end
