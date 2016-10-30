class UsersController < ApplicationController
  before_action :lookup_user, only: [:show, :update, :settings, :due_for_judgement, :statistics]
  before_action :authenticate_user!, only: [:settings, :update, :generate_api_token]
  before_action :user_must_be_current_user, only: [:settings, :update]

  helper_method :statistics

  def show
    @title       = "Most recent predictions by #{@user}"
    @predictions = @user.predictions
    @predictions = @predictions.not_private unless user_is_current_user?
    @predictions = @predictions.page params[:page]
  end

  def update
    @user.update_attributes(user_params)
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

  def statistics
    @statistics ||= @user.present? ? @user.statistics : Statistics.new
  end

  def due_for_judgement
    @title = "Predictions by #{@user} due for judgement"
    @predictions = @user.predictions
    @predictions = @predictions.not_private unless user_is_current_user?
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
    @user = User.find_by_login(params[:id]) || User.find_by_id(params[:id])
    render status: :not_found if @user.nil?
  end

  def user_is_current_user?
    current_user == @user
  end

  def user_must_be_current_user
    render status: :forbidden unless user_is_current_user?
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
    params.require(:user).permit(:login, :email, :name, :timezone, :private_default, :api_token)
  end
end
