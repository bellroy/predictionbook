# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :assign_group_member, only: %i[show]

  def index
    group_members = current_user.group_members.includes(group: :group_members)
    @groups = group_members.reject(&:invitee?).map(&:group).sort_by(&:name)
  end

  def show
    @group = @group_member.try(:group)
    raise ActionController::RoutingError, 'Not Found' if @group.nil? || @group_member.invitee?

    @statistics = @group.statistics
    @score_calculator = ScoreCalculator.new(@group, start_date: 6.months.ago, interval: 1.month)
    @predictions =
      Prediction.where(group: @group).page(params[:page]).includes(Prediction::DEFAULT_INCLUDES)
  end

  private

  def assign_group_member
    @group_member = current_user.group_members.includes(:group).where(group_id: params[:id]).first
  end
end
