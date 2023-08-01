# frozen_string_literal: true

module Api
  class MyPredictionsController < AuthorisedController
    def index
      ps = PredictionsQuery.new(
        page: params[:page].to_i,
        page_size: params[:page_size].to_i,
        predictions: @user.predictions.not_withdrawn,
        status: 'recent',
        tag_names: params.fetch(:tag_names, [])
      ).call
      serialized_predictions = ps.map { |p| PredictionSerializer.new(p).serializable_hash }
      render json: { user: @user.to_h, predictions: serialized_predictions }
    end
  end
end
