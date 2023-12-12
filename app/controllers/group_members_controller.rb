# frozen_string_literal: true

class GroupMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :assign_group
  before_action :assign_current_user_group_member
  before_action :must_be_member_of_group

  def index
    @group_members = Group
      .find(params[:group_id])
      .group_members
      .includes(:user)
      .sort_by { |gm| gm.user.login || 'anonymous' }
  end

  private

  def assign_group
    @group = Group.find(params[:group_id])
  end

  def assign_current_user_group_member
    @current_user_group_member = @group.group_members.find { |gm| gm.user_id == current_user.id }
  end

  def must_be_member_of_group
    notice = 'You are not authorized to perform that action'
    redirect_to(root_path, notice: notice) if @current_user_group_member.blank? ||
                                              @current_user_group_member.invitee?
  end
end
