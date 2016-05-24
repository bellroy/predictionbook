module Api
  class PredictionsController < ApplicationController
    MAXIMUM_PREDICTIONS_LIMIT = 1000
    DEFAULT_PREDICTIONS_LIMIT = 100

    before_action :authenticate_by_api_token
    before_action :build_predictions, only: [:index]
    before_action :build_new_prediction, only: [:create]
    before_action :find_prediction, only: [:show, :update]
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
      if @prediction.update_attributes(prediction_params)
        render json: @prediction
      else
        render json: @prediction.errors, status: :unprocessable_entity
      end
    end

    private

    def authenticate_by_api_token
      @user = User.find_by_api_token(params[:api_token])
      render json: invalid_api_message, status: :unauthorized unless valid_params_and_user?
    end

    def authorize_to_see_prediction
      raise UnauthorizedRequest unless @prediction.public? || @user.authorized_for(@prediction)
    end

    def authorize_to_update_prediction
      raise UnauthorizedRequest unless @user.authorized_for(@prediction)
    end

    def build_new_prediction
      unless prediction_params[:private] && @user
        prediction_params[:private] = @user.private_default
      end

      @prediction = Prediction.new(prediction_params.merge(creator: @user))
    end

    def build_predictions
      limit = params[:limit].to_i
      limit = DEFAULT_PREDICTIONS_LIMIT unless (1..MAXIMUM_PREDICTIONS_LIMIT).cover?(limit)
      @predictions = Prediction.recent(limit: limit)
    end

    def find_prediction
      @prediction = Prediction.find(params[:id])
    end

    def invalid_api_message
      { error: 'invalid API token', status: :unauthorized }
    end

    def valid_params_and_user?
      params[:api_token] && @user
    end

    def prediction_params
      params.require(:prediction).permit!
    end
  end
end
