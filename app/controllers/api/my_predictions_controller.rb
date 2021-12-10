# frozen_string_literal: true

module Api
  class MyPredictionsController < AuthorisedController
    def index
      render json: { user: @user.to_h, predictions: prediction_hash_array }
    end

    private

    def prediction_hash_array
      predictions.map do |prediction|
        PredictionSerializer.new(prediction).serializable_hash
      end
    end

    def predictions
      PredictionsQuery.new(
        creator: @user,
        page: params[:page].to_i,
        page_size: params[:page_size].to_i
      ).call
    end
  end
end
