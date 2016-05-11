class UsersController < ApplicationController
  before_action :lookup_user, only: [:show, :update, :settings, :due_for_judgement]
  before_action :authenticate_user!, only: [:settings, :update, :generate_api_token]
  before_action :user_is_current_user, only: [:settings, :update]

  helper_method :statistics

  # On the sign-up page, fill in an existing user name and click "Sign
  # Up". Then switch to the sign-in page, fill in your credentials and click
  # "Log In". You will be redirected to /users, a page that doesn't exist.
  #
  # See https://github.com/tricycle/predictionbook/issues/58
  #
  # Redirects /users to the root path to resolve this issue
  def index
    redirect_to root_path
  end

  def show
    @title       = "Most recent predictions by #{@user}"
    @predictions = @user.predictions.limit(100)
    @predictions = @predictions.not_private unless current_user == @user
  end

  def new
    @title = 'Signup'
    @user = User.new
  end

  def update
    @user.update_attributes(params[:user])
    if @user.valid?
      show
      render action: :show
    else
      settings
      render action: :settings
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
      flash[:notice] = 'Thanks for signing up!'
    else
      flash[:error]  = "We couldn't set up that account, sorry."
      render action: 'new'
    end
  end

  def statistics
    @statistics ||= @user.statistics
  end

  def due_for_judgement
    @title = "Predictions by #{@user} due for judgement"
    @predictions = @user.predictions
    @predictions = @predictions.not_private unless current_user == @user
    @predictions = @predictions.select(&:due_for_judgement?)
  end

  def generate_api_token
    if updated_user_api_token?
      flash[:notice] = 'Generated a new API token!'
    else
      flash[:error]  = update_api_token_error_message
    end

    redirect_to settings_user_url(current_user)
  end

  protected

  def lookup_user
    @user = User[params[:id]]
  end

  def user_is_current_user
    access_forbidden unless current_user == @user
  end

  private

  def updated_user_api_token?
    current_user &&
      current_user.update_attributes(api_token: User.generate_api_token)
  end

  def update_api_token_error_message
    'Unable to generate new API token due to these errors:' +
      current_user.errors.full_messages.to_sentence + '.' \
      'Please ensure your user profile is complete.'
  end

  def user_params
    attributes = [:login, :email, :name, :password, :password_confirmation, :timezone,
                  :private_default, :api_token]
    attributes << :admin if current_user.admin?
  end
end
