# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def create
    notification = notification_collection.create!(notification_params)
    redirect_or_render(notification)
  end

  def update
    notification = notification_collection.find(params[:id])
    notification.update_attributes!(notification_params)
    redirect_or_render(notification)
  end

  def underscored_notification_type
    notification_type.to_s.underscore
  end

  def notification_collection
    current_user.send(underscored_notification_type.pluralize)
  end

  private

  def redirect_or_render(notification)
    if request.xhr?
      render partial: notification
    else
      redirect_to prediction_path(notification.prediction)
    end
  end

  def notification_params
    params.require(underscored_notification_type).permit(:prediction_id, :enabled)
  end
end
