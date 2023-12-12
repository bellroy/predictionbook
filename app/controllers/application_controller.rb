# frozen_string_literal: true

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include ActionController::Caching::Sweeping

  class UnauthorizedRequest < StandardError
  end

  helper :all # include all helpers, all the time

  before_action :set_timezone, :clear_return_to
  before_action :configure_permitted_parameters, if: :devise_controller?

  protect_from_forgery with: :exception, prepend: true

  protected

  def configure_permitted_parameters
    added_attrs = %i[login email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs + %i[crypted_password salt]
  end

  private

  def set_timezone
    user_timezone = current_user.try(:timezone)
    Time.zone = user_timezone.presence || 'UTC'
    Chronic.time_class = Time.zone
  end

  def clear_return_to
    session[:return_to] = nil
  end
end
