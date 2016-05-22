# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  class UnauthorizedRequest < StandardError
  end

  helper :all # include all helpers, all the time

  before_action :set_timezone, :clear_return_to, :login_via_token

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'c4ec086ac06ce802c8f49e28cc1e8943'

  protected

  def handle_unauthorised_request
    render json: unauthorized_user_message, status: :unauthorized
  end

  def configure_permitted_parameters
    added_attrs = [:name, :login, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  private

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
      DeadlineNotification.use_token!(token) { |dn| self.current_user = dn.user }
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
