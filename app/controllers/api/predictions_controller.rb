# frozen_string_literal: true

module Api
  class PredictionsController < AuthorisedController
    MAXIMUM_PREDICTIONS_LIMIT = 1000
    DEFAULT_PREDICTIONS_LIMIT = 100

    before_action :build_predictions, only: [:index]
    before_action :find_prediction, only: %i[show]
    before_action :authorize_to_see_prediction, only: [:show]

    def index
      render json: @predictions
    end

    def show
      render json: @prediction
    end

    private

    def authorize_to_see_prediction
      raise UnauthorizedRequest unless @prediction.visible_to_everyone? ||
                                       @user.authorized_for?(@prediction)
    end

    def build_predictions
      limit = params[:limit].to_i
      limit = DEFAULT_PREDICTIONS_LIMIT unless (1..MAXIMUM_PREDICTIONS_LIMIT).cover?(limit)
      @predictions = if params[:page_number].blank?
                       Prediction.visible_to_everyone.recent.limit(limit)
                     else
                       page_number = [params[:page_number].to_i, 1].max - 1
                       Prediction
                        .visible_to_everyone
                        .not_withdrawn
                        .includes(Prediction::DEFAULT_INCLUDES)
                        .order(created_at: :asc)
                        .limit(limit)
                        .offset(page_number * limit)
                     end
    end

    def find_prediction
      @prediction = Prediction.find(params[:id])
    end
  end
end
