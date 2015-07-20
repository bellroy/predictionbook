module Api
  class PredictionsController < ApplicationController
    before_filter :authenticate
    before_filter :must_be_authorized_for_prediction, only: [:withdraw, :update]

    def index
      @predictions = Prediction.limit(100).recent

      render json: @predictions, status: 200
    end

    def create
      if build_prediction.save
        render json: @prediction, status: 200
      else
        render json: @prediction.errors, status: 422
      end
    end

    private

    def authenticate
      @user = User.find_by_api_token(params[:api_token])
      
      render json: invalid_message, status: 401 unless @user
    end

    def build_prediction
      prediction_params = params[:prediction] || {}

      unless prediction_params[:private]
        prediction_params[:private] = @user.private_default
      end

      Prediction.new(prediction_params.merge(creator: @user))
    end

    def invalid_message
      { error: 'invalid API token', status: 401 }
    end
  end
end