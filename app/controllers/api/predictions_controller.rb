module Api
  class PredictionsController < ApplicationController
    PREDICTIONS_LIMIT = 1000
    
    before_filter :authenticate_by_api_token
    before_filter :must_be_authorized_for_prediction, only: [:withdraw, :update]
    before_filter :predictions, only: [:index]

    def index
      if @user && params[:api_token]
        render json: @predictions, status: 200
      else
        render json: invalid_message, status: 401
      end
    end

    def create
      if build_prediction.save
        render json: @prediction, status: 200
      else
        render json: @prediction.errors, status: 422
      end
    end

    private

    def authenticate_by_api_token
      @user = User.find_by_api_token(params[:api_token]) rescue nil
    end

    def build_prediction
      prediction_params = params[:prediction] || {}

      unless prediction_params[:private]
        prediction_params[:private] = @user.private_default
      end

      Prediction.new(prediction_params.merge(creator: @user))
    end

    def predictions
      if params[:limit] && params[:limit] < PREDICTIONS_LIMIT
        @predictions = Prediction.limit(params[:limit]).recent
      else
        @predictions = Prediction.limit(100).recent
      end
    end

    def invalid_message
      { error: 'invalid API token', status: 401 }
    end

    def must_be_authorized_for_prediction
    end
  end
end
