module Api
  class PredictionsController < ApplicationController
    MAXIMUM_PREDICTIONS_LIMIT = 1000
    DEFAULT_PREDICTIONS_LIMIT = 100

    before_filter :authenticate_by_api_token
    before_filter :build_predictions, only: [:index]
    before_filter :find_prediction, only: [:show]

    def create
      @prediction = build_new_prediction

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
      if user_is_authorized_for_prediction
        render json: @prediction
      else
        render json: unauthorized_user_message, status: :unauthorized
      end
    end

    private

    def authenticate_by_api_token
      @user = User.find_by_api_token(params[:api_token])

      unless valid_params_and_user?
        render json: invalid_api_message, status: :unauthorized
      end
    end

    def build_new_prediction
      prediction_params = params[:prediction] || {}

      unless prediction_params[:private] && @user
        prediction_params[:private] = @user.private_default
      end

      Prediction.new(prediction_params.merge(creator: @user))
    end

    def build_predictions
      if (1..MAXIMUM_PREDICTIONS_LIMIT).include?(params[:limit].to_i)
        @predictions = Prediction.limit(params[:limit].to_i).recent
      else
        @predictions = Prediction.limit(DEFAULT_PREDICTIONS_LIMIT).recent
      end
    end

    def find_prediction
      @prediction = Prediction.find(params[:id])
    end

    def invalid_api_message
      { error: 'invalid API token', status: :unauthorized }
    end

    def unauthorized_user_message
      {
        error: 'user is unauthorized to view this private prediction',
        status: :unauthorized
      }
    end

    def user_is_authorized_for_prediction
      return true unless @prediction.private?
      @user.authorized_for(@prediction)
    end

    def valid_params_and_user?
      params[:api_token] && @user
    end
  end
end
