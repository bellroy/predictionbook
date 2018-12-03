# frozen_string_literal: true

class GroupMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :assign_group
  before_action :assign_current_user_group_member
  before_action :assign_group_member, only: %i[edit update destroy]
  before_action :must_be_member_of_group
  before_action :must_be_admin_for_group, only: %i[new create update destroy]

  def index
    @group_members = Group
      .find(params[:group_id])
      .group_members
      .includes(:user)
      .sort_by { |gm| gm.user.login || 'anonymous' }
  end

  def new
    @group_member = GroupMember.new
  end

  def create
    user = User.find_by(login: params[:login])

    @group_member = GroupMember.new(group: @group, user: user, role: 'invitee')
    if user.present? && @group_member.save
      @group_member.send_invitation
      redirect_to group_group_members_path(@group)
    else
      flash[:error] = if user.nil?
                        'There is no PredictionBook user with that login'
                      else
                        @group_member.errors.full_messages.join(',')
                      end
      render :new
    end
  end

  def update
    role_param = params[:role]
    if role_param.present? && GroupMember::ROLES.key?(role_param.to_sym)
      @group_member.update(role: role_param)
    else
      @group_member.send_invitation
    end
    redirect_to group_group_members_path(@group)
  end

  def destroy
    @group_member.send_ejection
    @group_member.destroy
    redirect_to group_group_members_path(@group),
                notice: "User '#{@group_member.user.login}' has been removed from the group."
  end

  private

  def assign_group
    @group = Group.find(params[:group_id])
  end

  def assign_group_member
    @group_member = GroupMember.find(params[:id])
  end

  def assign_current_user_group_member
    @current_user_group_member = @group.group_members.find { |gm| gm.user_id == current_user.id }
  end

  def must_be_member_of_group
    notice = 'You are not authorized to perform that action'
    redirect_to(root_path, notice: notice) if @current_user_group_member.blank? ||
                                              @current_user_group_member.invitee?
  end

  def must_be_admin_for_group
    notice = 'You are not authorized to perform that action'
    redirect_to(group_path(@group), notice: notice) unless @current_user_group_member.try(:admin?)
  end
end
