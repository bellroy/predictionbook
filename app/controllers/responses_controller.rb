class ResponsesController < ApplicationController
  before_action :authenticate_user!, except: :index

  def index
    @responses = Response.limit(50).recent
  end

  def create
    @prediction_response = prediction.responses.new(params[:response].merge(user: current_user))

    unless @prediction_response.save # creation failed
      flash[:error] = 'You must enter an estimate or comment'
    end
    redirect_to prediction_path(prediction)
  end

  def preview
    @response = Response.new(params[:response])
    render partial: 'preview'
  end

  private

  def prediction
    @prediction ||= Prediction.find(params[:prediction_id])
  end
end
