# frozen_string_literal: true

class PredictionGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_prediction_group, only: %i[show]
  before_action :must_be_authorized_for_prediction, only: %i[show]

  def show
    @events = @prediction_group.predictions.flat_map(&:events).sort_by(&:created_at)
    @title = @prediction_group.description
  end

  private

  def must_be_authorized_for_prediction
    prediction = @prediction_group.predictions.first || Prediction.new
    action = params[:action]
    authorized = (current_user || User.new).authorized_for?(prediction, action)
    showing_public_prediction = (action == 'show' && prediction.visible_to_everyone?)
    notice = 'You are not authorized to perform that action'
    redirect_to(root_path, notice: notice) unless authorized || showing_public_prediction
  end

  def find_prediction_group
    @prediction_group = PredictionGroup.includes(predictions: %i[responses versions judgements])
      .find(params[:id])
  end
end
