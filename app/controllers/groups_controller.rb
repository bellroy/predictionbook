class GroupsController < ApplicationController
  before_action :authenticate_user!

  def index
    raise ActionController::RoutingError, 'Not Found' if @groups.blank?
  end

  def show
    @group = @groups.find { |group| group.id == params[:id] }
    raise ActionController::RoutingError, 'Not Found' if @group.nil?
    @predictions = Prediction.where(group: @group).page(params[:page])
  end
end
