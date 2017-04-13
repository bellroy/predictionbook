class UsersController < ApplicationController
  before_action :lookup_user, only: [:show, :update, :settings, :due_for_judgement, :statistics]
  before_action :authenticate_user!, only: [:settings, :update, :generate_api_token]
  before_action :user_must_be_current_user, only: [:settings, :update]

  def show
    @title       = "Most recent predictions by #{@user}"
    @predictions = @user.predictions
    @statistics  = @user.statistics
    @predictions = @predictions.visible_to_everyone unless user_is_current_user?
    @predictions = @predictions.page(params[:page])
  end

  def update
    @user.assign_attributes(user_params)
    if @user.valid?
      @user.save!
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
    @heading = params[:heading] || 'Statistics'
    @statistics ||= @user.present? ? @user.statistics : Statistics.new
    layout = case params[:layout]
             when nil
               'application'
             when 'none'
               nil
             else
               params['layout']
             end
    render :statistics, layout: layout
  end

  def due_for_judgement
    @title = "Predictions by #{@user} due for judgement"
    @predictions = @user.predictions
    @predictions = @predictions.visible_to_everyone unless user_is_current_user?
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

  def ensure_statistics
    @statistics = Statistics.new
  end

  def lookup_user
    id_param = params[:id]
    @user = User.find_by(login: id_param) || User.find_by(id: id_param)
    if !@user && params[:action] == 'statistics'
      @user = User.find_by(api_token: id_param)
    end
    raise ActiveRecord::RecordNotFound if @user.nil?
  end

  def user_is_current_user?
    current_user == @user
  end

  def user_must_be_current_user
    head :forbidden unless user_is_current_user?
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
    permitted_params = params.require(:user).permit(:login, :email, :name, :timezone,
                                                    :visibility_default, :api_token)
    visibility_default = permitted_params[:visibility_default]
    if visibility_default.present?
      attributes = Visibility.option_to_attributes(visibility_default)
      permitted_params[:visibility_default] = attributes[:visibility]
      permitted_params[:group_default_id] = attributes[:group_id]
    end
    permitted_params
  end
end
