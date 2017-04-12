class GroupsController < ApplicationController
  before_action :authenticate_user!

  def index
    raise ActionController::RoutingError, 'Not Found' if @groups.blank?
  end

  def show
    @group = Group.find(params[:id])
    raise ActionController::RoutingError, 'Not Found' unless @groups.include?(@group)
    @predictions = Prediction.where(group: @group).page(params[:page])
  end
end
