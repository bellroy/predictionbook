class Api::PredictionsController < ApplicationController

  before_filter :authenticate
  before_filter :must_be_authorized_for_prediction, :only => [:withdraw, :edit, :update]

  def index
    @predictions = Prediction.limit(100).recent
    render json: @predictions, status: 200
  end

  protected

  def authenticate
    @user = User.authenticate(params[:username], params[:password])
    render json: invalid_message, status: 401 unless @user
  end

  def invalid_message
    { error: 'invalid username, password, or both', status: 401 }
  end

end
