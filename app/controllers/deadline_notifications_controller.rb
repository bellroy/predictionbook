class DeadlineNotificationsController < NotificationsController
  
  def index
    @user = User[params[:user_id]]
    
    @pending = @user.deadline_notifications.sendable.sort
    @waiting = @user.deadline_notifications.unsent.enabled.unknown.sort
    @known = @user.deadline_notifications.unsent.enabled.known.rsort(:judged_at)
    @sent = @user.deadline_notifications.sent.rsort(:deadline)
  end
  
  def notification_type
    DeadlineNotification
  end
end