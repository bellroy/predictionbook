class DeadlineNotificationsController < NotificationsController
  def index
    @user = User.find_by_login(params[:user_id]) || User.find_by_id(params[:user_id])

    @pending = @user.deadline_notifications.sendable.sort
    @pending = Kaminari.paginate_array(@pending).page(params[:page]).per(20)
    @waiting = @user.deadline_notifications.unsent.enabled.unknown.sort
    @waiting = Kaminari.paginate_array(@waiting).page(params[:page]).per(20)
    @known = @user.deadline_notifications.unsent.enabled.known.rsort(:judged_at)
    @known = Kaminari.paginate_array(@known).page(params[:page]).per(20)
    @sent = @user.deadline_notifications.sent.rsort(:deadline)
    @sent = Kaminari.paginate_array(@sent).page(params[:page]).per(20)
  end

  def notification_type
    DeadlineNotification
  end
end
