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

    class PredictionsQuery
      DEFAULT_PAGE = 1
      DEFAULT_PAGE_SIZE = 100
      MAXIMUM_PAGE_SIZE = 1000

      def initialize(user:, page: DEFAULT_PAGE, page_size: DEFAULT_PAGE_SIZE)
        @page = page
        @page_size = page_size
        @user = user
      end

      def call
        user
          .predictions
          .not_withdrawn
          .includes(Prediction::DEFAULT_INCLUDES)
          .order(created_at: :desc)
          .page(page)
          .per(page_size)
      end

      private

      attr_reader :user

      def page
        if @page.positive?
          @page
        else
          DEFAULT_PAGE
        end
      end

      def page_size
        if (1..MAXIMUM_PAGE_SIZE).cover?(@page_size)
          @page_size
        else
          DEFAULT_PAGE_SIZE
        end
      end
    end
  end
end
