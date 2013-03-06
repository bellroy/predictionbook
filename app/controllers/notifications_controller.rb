class NotificationsController < ApplicationController
  before_filter :login_required
  
  def create
    n = notification_collection.create!(params[notification])
    redirect_or_render(n)
  end
  
  def update
    n = notification_collection.find(params[:id])
    n.update_attributes!(params[notification])
    redirect_or_render(n)
  end
  
  def notification
    notification_type.to_s.underscore
  end
  
  def notification_collection
    current_user.send(notification.pluralize)
  end
  
  private
  def redirect_or_render(notification)
    if request.xhr?
      render :partial => notification
    else
      redirect_to prediction_path(notification.prediction)
    end
  end
end