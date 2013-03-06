class ResponsesController < ApplicationController
  before_filter :login_required, :except => :index
  
  def index
    @responses = Response.recent.limit(50)
  end
  
  def create
    prediction.responses.create!(params[:response].merge(:user => current_user))
    redirect_to prediction_path(prediction)
  rescue ActiveRecord::RecordInvalid => invalid
    @prediction_response = invalid.record
    @events = @prediction.events
    render :template => 'predictions/show', :status => :unprocessable_entity
  end
  
  def preview
    @response = Response.new(params[:response])
    render :partial => 'preview'
  end
  
private
  def prediction
    @prediction ||= Prediction.find(params[:prediction_id])
  end
  
end
