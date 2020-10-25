# frozen_string_literal: true

module Api
  class PredictionsController < AuthorisedController
    MAXIMUM_PREDICTIONS_LIMIT = 1000
    DEFAULT_PREDICTIONS_LIMIT = 100

    before_action :build_predictions, only: [:index]
    before_action :build_new_prediction, only: [:create]
    before_action :find_prediction, only: %i[show update]
    before_action :authorize_to_see_prediction, only: [:show]
    before_action :authorize_to_update_prediction, only: [:update]

    def create
      if @prediction.save
        render json: @prediction
      else
        render json: @prediction.errors, status: :unprocessable_entity
      end
    end

    def index
      render json: @predictions
    end

    def show
      render json: @prediction
    end

    def update
      if @prediction.update(prediction_params)
        render json: @prediction
      else
        render json: @prediction.errors, status: :unprocessable_entity
      end
    end

    private

    def authorize_to_see_prediction
      raise UnauthorizedRequest unless @prediction.visible_to_everyone? ||
                                       @user.authorized_for?(@prediction)
    end

    def authorize_to_update_prediction
      raise UnauthorizedRequest unless @user.authorized_for?(@prediction)
    end

    def build_new_prediction
      permitted_params = prediction_params
      permitted_params[:visibility] ||= @user.try(:visibility_default)
      @prediction = Prediction.new(permitted_params.merge(creator: @user))
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

    def prediction_params
      permitted_params = params.require(:prediction).permit!
      # Handle previous version of the API that uses a private flag instead of visibility
      if permitted_params[:private].present?
        private_value = permitted_params.delete(:private)
        permitted_params[:visibility] = 'visible_to_creator' if private_value
      end
      permitted_params
    end
  end
end
