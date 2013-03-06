# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  skip_before_filter :clear_return_to

  # render new.rhtml
  def new
    @title = "Logging in"
    store_referer_if_no_destination
  end

  def create
    logout_keeping_session!
    auth_params = params[:user]
    user = User.authenticate(auth_params[:login], auth_params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (auth_params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin(auth_params)
      @login       = auth_params[:login]
      @remember_me = auth_params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    store_referer_if_no_destination unless referer_requires_login?
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin(auth)
    flash[:error] = "Couldn't log you in as '#{auth[:login]}'"
    logger.warn "Failed login for '#{auth[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
