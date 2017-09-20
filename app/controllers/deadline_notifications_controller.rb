# frozen_string_literal: true

class DeadlineNotificationsController < NotificationsController
  def index
    id_param = UserLogin.new(params[:user_id]).to_s
    @user = User.find_by(login: id_param) || User.find_by(id: id_param)

    @pending = @user.deadline_notifications.sendable.sort
    @waiting = @user.deadline_notifications.unsent.enabled.unknown.sort
    @known = @user.deadline_notifications.unsent.enabled.known.sort_by(&:judged_at)
    @sent = @user.deadline_notifications.sent.sort_by(&:deadline)
  end

  def notification_type
    DeadlineNotification
  end
end
