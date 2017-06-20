class GroupsController < ApplicationController
  before_action :authenticate_user!

  def index
    @groups = current_user.try(:groups) || []
    raise ActionController::RoutingError, 'Not Found' if @groups.blank?
  end

  def show
    groups = current_user.try(:groups) || []
    @group = groups.find { |group| group.id == params[:id].to_i }
    raise ActionController::RoutingError, 'Not Found' if @group.nil?
    @predictions =
      Prediction.where(group: @group).page(params[:page]).includes(Prediction::DEFAULT_INCLUDES)
  end
end
