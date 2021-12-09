# frozen_string_literal: true

module Api
  class MyPredictionsController < AuthorisedController
    def index
      render json: my_predictions_hash
    end

    private

    def my_predictions_hash
      prediction_hash_array = predictions.map do |prediction|
        PredictionSerializer.new(prediction).serializable_hash
      end

      {
        user: { user_id: @user.id, name: @user.name, email: @user.email },
        predictions: prediction_hash_array
      }
    end

    def predictions
      PredictionsQuery.new(
        user: @user,
        page: params[:page].to_i,
        page_size: params[:page_size].to_i
      ).call
    end
  end
end
