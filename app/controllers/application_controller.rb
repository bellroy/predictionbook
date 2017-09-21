# frozen_string_literal: true

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include ActionController::Caching::Sweeping

  class UnauthorizedRequest < StandardError
  end

  helper :all # include all helpers, all the time

  before_action :set_timezone, :clear_return_to, :login_via_token
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :force_change_password

  protect_from_forgery with: :exception, prepend: true

  protected

  def handle_unauthorised_request
    render json: unauthorized_user_message, status: :unauthorized
  end

  def configure_permitted_parameters
    added_attrs = %i[login email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs + %i[crypted_password salt]
  end

  private

  def force_change_password
    return unless current_user.present? && request.format.html?
    notice = 'PredictionBook has recently undergone a major upgrade. As part of the upgrade, our ' \
             'authentication system has changed. We are currently transitioning users across to ' \
             'use the new authentication system. You will need to change your password and ' \
             'provide an email address if you have not already.'
    force_pwd_change = !current_user.devise_password_specified?
    redirecting = request.path == edit_user_registration_path
    updating_password = request.path == '/users' && params['_method'] == 'put'
    logging_out = request.path == destroy_user_session_path
    redirect_to(edit_user_registration_path, notice: notice) if force_pwd_change && !redirecting &&
                                                                !updating_password && !logging_out
  end

  def set_timezone
    user_timezone = current_user.try(:timezone)
    Time.zone = user_timezone.blank? ? 'UTC' : user_timezone
    Chronic.time_class = Time.zone
  end

  def clear_return_to
    session[:return_to] = nil
  end

  def login_via_token
    token = params[:token]
    if token.present?
      DeadlineNotification.use_token!(token) { |dn| @current_user = dn.user }
      redirect_to # get rid of token in url so if it is copied and pasted it's not propagated
    end
  end

  def unauthorized_user_message
    {
      error: 'user is unauthorized to view/edit this private prediction',
      status: :unauthorized
    }
  end
end
