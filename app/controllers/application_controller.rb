# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  unloadable # restful_authentication breaks rails class reloading in dev mode, a fix would be appreciated immensely
  include AuthenticatedSystem
  
  before_filter :set_timezone, :clear_return_to, :login_via_token

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'c4ec086ac06ce802c8f49e28cc1e8943'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  private
  def set_timezone
    if logged_in? && !current_user.timezone.blank?
      Time.zone = current_user.timezone
    else
      Time.zone = 'UTC'
    end
    Chronic.time_class = Time.zone
  end
  
  def clear_return_to
    session[:return_to] = nil
  end
  
  def login_via_token
    if token = params[:token]
      DeadlineNotification.use_token!(token) do |dn|
        self.current_user = dn.user
      end
      redirect_to # get rid of token in url so if it is copied and pasted it's not propagated 
    end
  end
end
