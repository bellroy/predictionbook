class PasswordsController < ApplicationController
  before_filter :not_logged_in_required

  def create
    user = User.find_by_login_and_email(params[:login], params[:email])

    if user
      user.reset_password

      session[:return_to] = settings_user_path(user)
      flash[:notice] = "We sent your new password to #{user.email}"
      redirect_to login_path
    else
      flash[:error] = "We couldn't find a user with matching login and email"
      render :new
    end
  rescue ActiveRecord::RecordInvalid
    flash[:error] = "We couldn't reset your password. Please try again"
    render :new
  end
end

