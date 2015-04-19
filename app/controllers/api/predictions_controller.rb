class Api::PredictionsController < ApplicationController

  before_filter :authenticate

  def index
    @predictions = Prediction.limit(100).recent
    render json: @predictions, status: 200
  end

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      User.authenticate(username, password)
    end
  end

end
