# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :lookup_user, only: %i[show settings statistics]
  before_action :authenticate_user!, only: %i[settings]
  before_action :user_must_be_current_user, only: %i[settings]
  before_action :allow_iframe_requests, only: :statistics

  def show
    @title = "Most recent predictions by #{@user}"
    @predictions = showable_predictions
    @statistics = @user.statistics
    @score_calculator = ScoreCalculator.new(@user, start_date: 6.months.ago, interval: 1.month)
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

  protected

  def lookup_user
    id_param = UserLogin.new(params[:id]).to_s
    @user = User.find_by(login: id_param) || User.find_by(id: id_param)
    raise ActiveRecord::RecordNotFound if @user.nil?
  end

  def user_is_current_user?
    current_user == @user
  end

  def user_must_be_current_user
    head :forbidden unless user_is_current_user?
  end

  private

  def showable_predictions
    predictions = @user.predictions
    predictions = predictions.visible_to_everyone unless current_user == @user

    PredictionsQuery.new(
      page: params[:page].to_i,
      predictions: predictions,
      status: params[:filter],
      tag_names: Array.wrap(params[:tags]).reject(&:blank?)
    ).call
  end

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end
end
