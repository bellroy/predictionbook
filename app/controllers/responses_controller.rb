class ResponsesController < ApplicationController
  before_action :authenticate_user!, except: :index

  def index
    @responses = Response.recent(limit: 50)
  end

  def create
    @prediction_response = prediction.responses.new(response_params)
    flash[:error] = 'You must enter an estimate or comment' unless @prediction_response.save
    redirect_to prediction_path(prediction)
  end

  def preview
    @response = Response.new(response_params)
    render partial: 'preview'
  end

  private

  def prediction
    @prediction ||= Prediction.find(params[:prediction_id])
  end

  def response_params
    result = params.require(:response).permit!
    result[:user_id] = current_user.id if params[:action] == 'create'
    result
  end
end
