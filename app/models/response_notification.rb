# frozen_string_literal: true

class ResponseNotification < Notification
  def deliver
    Deliverer.response_notification(self).deliver
  end

  def viewed!
    unless new_record?
      update!(
        sent: false,
        token_used: false,
        new_activity: false
      )
    end
  end

  def new_activity!
    update!(new_activity: true)
  end

  def sendable?
    enabled? && has_email? && new_activity?
  end
end
