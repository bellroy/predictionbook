module DeadlineHelper
  def deadline_notification_info(deadline_notification)
    set_your_email = link_to "set your email", settings_user_path(deadline_notification.user)
    if deadline_notification.sent?
      "Your email notification has been sent."
    elsif deadline_notification.sendable?
      "Your email notification will be sent soon."
    elsif deadline_notification.due_for_judgement? and deadline_notification.enabled?
      "To receive your notifications, #{set_your_email}"
    elsif deadline_notification.deadline < Time.current and deadline_notification.enabled?
      "You would have been notified #{show_time(deadline_notification.deadline)}, but it was already judged."
    else
      time = show_time(deadline_notification.deadline)
      will_would = deadline_notification.enabled ? 'will be' : 'would be'
      will_would = 'would have been' if deadline_notification.overdue?
      if deadline_notification.has_email?
        "You #{will_would} notified #{time}."
      else
        "You #{will_would} notified #{time} if you #{set_your_email}."
      end
    end
  end
  
  def deadline_notification_disabled(deadline_notification)
    content_tag(:em, 'Notification when the outcome should be known') + ' ' +
    if deadline_notification.withdrawn?
      'unavailable as the prediction has been withdrawn.'
    elsif !deadline_notification.open?
      'unavailable as the prediction has already been judged.'
    elsif deadline_notification.overdue?
      'unavailable as the deadline has already passed.'
    else
      'unavailable.'
    end
  end
end