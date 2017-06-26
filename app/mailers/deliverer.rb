# encoding: utf-8
# frozen_string_literal: true

class Deliverer < ApplicationMailer
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
end
