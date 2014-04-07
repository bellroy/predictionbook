class ResponsesController < ApplicationController
  before_filter :login_required, :except => :index

  def index
    @responses = Response.recent.limit(50)
  end

  def create
    build_resource              # try to create a new response

    unless @resource.save       # creation failed
      flash[:error] = "Response creation failed, please make your comment is not empty."
    end
    redirect_to prediction_path(prediction)
  end

  def preview
    @response = Response.new(params[:response])
    render :partial => 'preview'
  end

private
  def prediction
    @prediction ||= Prediction.find(params[:prediction_id])
  end

  def build_resource
    @resource = prediction.responses.new(params[:response].merge(:user => current_user))
  end

end
