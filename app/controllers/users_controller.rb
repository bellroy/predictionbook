class UsersController < ApplicationController
  before_filter :lookup_user, :only => [:show, :update, :settings]
  before_filter :login_required, :only => [:settings, :update]
  before_filter :user_is_current_user, :only => [:settings, :update]
  
  helper_method :statistics

  def show
    @title = "Predictions by #{@user}"
    @predictions = @user.predictions
    @predictions = @predictions.not_private unless current_user == @user
  end

  def new
    @title = "Signup"
    @user = User.new
  end
 
  def update
    @user.update_attributes(params[:user])
    if @user.valid?
      show
      render :action => :show
    else
      settings
      render :action => :settings
    end
  end
  
  def settings
      @title = "Settings for #{current_user}"
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      flash[:error]  = "We couldn't set up that account, sorry."
      render :action => 'new'
    end
  end
  
  def statistics
    @statistics ||= @user.statistics
  end
  
  protected
  def lookup_user
    @user = User[params[:id]]
  end
  
  def user_is_current_user
    access_forbidden unless current_user == @user
  end
  
end
