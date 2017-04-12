class GroupsController < ApplicationController
  before_action :authenticate_user!

  def index
    raise ActionController::RoutingError, 'Not Found' if @groups.blank?
  end

  def show
    @group = Group.find(params[:id])
    @predictions = Prediction.where('1 = 0').page(1)
    raise ActionController::RoutingError, 'Not Found' unless @groups.include?(@group)
  end
end
