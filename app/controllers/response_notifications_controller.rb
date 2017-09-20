# frozen_string_literal: true

class ResponseNotificationsController < NotificationsController
  def notification_type
    ResponseNotification
  end
end
