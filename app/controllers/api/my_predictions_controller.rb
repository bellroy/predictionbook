# frozen_string_literal: true

module Api
  class MyPredictionsController < AuthorisedController
    MAXIMUM_PAGE_SIZE = 1000
    DEFAULT_PAGE_SIZE = 100
    DEFAULT_PAGE = 1

    def index
      render json: my_predictions
    end

    private

    def my_predictions
      page_size = params[:page_size].to_i
      page_size = DEFAULT_PAGE_SIZE unless (1..MAXIMUM_PAGE_SIZE).cover?(page_size)
      page = params[:page].to_i
      page = DEFAULT_PAGE unless page.positive?
      @predictions = @user.predictions
                          .includes(Prediction::DEFAULT_INCLUDES)
                          .order(created_at: :desc)
                          .page(page)
                          .per(page_size)
    end
  end
end
