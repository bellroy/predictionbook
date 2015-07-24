module Api
  class PredictionsController < ApplicationController
    PREDICTIONS_LIMIT = 1000

    before_filter :authenticate_by_api_token
    before_filter :build_predictions, only: [:index]

    def index
      render json: @predictions, status: 200
    end

    def create
      @prediction = build_new_prediction

      if @prediction.save
        render json: @prediction
      else
        render json: @prediction.errors, status: 422
      end
    end

    private

    def authenticate_by_api_token
      @user = User.find_by_api_token(params[:api_token])
      render json: invalid_message, status: 401 unless valid_user_found?
    end
    
    def valid_user_found?
      params[:api_token] && @user
    end

    def build_new_prediction
      prediction_params = params[:prediction] || {}

      unless prediction_params[:private] && @user
        prediction_params[:private] = @user.private_default
      end

      Prediction.new(prediction_params.merge(creator: @user))
    end

    def build_predictions
      if params[:limit] && params[:limit].to_i <= PREDICTIONS_LIMIT
        @predictions = Prediction.limit(params[:limit].to_i).recent
      else
        @predictions = Prediction.limit(100).recent
      end
    end

    def invalid_message
      { error: 'invalid API token', status: 401 }
    end
  end
end
