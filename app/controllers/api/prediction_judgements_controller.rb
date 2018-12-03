# frozen_string_literal: true

module Api
  class PredictionJudgementsController < AuthorisedController
    def create
      @prediction = Prediction.find(params[:prediction_id])
      raise UnauthorizedRequest unless @user.authorized_for?(@prediction)

      @prediction.judge!(params[:outcome], @user)
      render status: :created, json: @prediction.judgements.last
    end
  end
end
