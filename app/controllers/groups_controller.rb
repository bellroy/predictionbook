# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :assign_group_member, only: %i[show edit update destroy]
  before_action :must_be_admin_for_group, only: %i[edit update destroy]

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

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    add_group_members
    if @group.save
      @group.group_members.each(&:send_invitation)
      redirect_to group_path(@group)
    else
      flash[:error] = @group.errors.full_messages.join(',')
      render :new
    end
  end

  def edit
    @group = @group_member.group
  end

  def update
    @group = @group_member.group
    @group.assign_attributes(group_params)
    if @group.save
      redirect_to group_path(@group)
    else
      flash[:error] = @group.errors.full_messages.join(',')
      render :edit
    end
  end

  def destroy
    @group = @group_member.group
    @group.destroy
    redirect_to groups_path, notice: "Group '#{@group.name}' has been destroyed. All predictions " \
                                     'visible to the group have been made private.'
  end

  private

  def assign_group_member
    @group_member = current_user.group_members.includes(:group).where(group_id: params[:id]).first
  end

  def must_be_admin_for_group
    notice = 'You are not authorized to perform that action'
    redirect_to(root_path, notice: notice) if @group_member.nil? || !@group_member.admin?
  end

  def group_params
    params.require(:group).permit(:name)
  end

  def add_group_members
    logins = (params[:invitees] || '').split("\n").take(20)
    User.where.not(login: [nil, '', current_user.login]).where(login: logins).each do |user|
      add_group_member(user, 'invitee')
    end
    add_group_member(current_user, 'admin')
  end

  def add_group_member(user, role)
    @group.group_members << GroupMember.new(group: @group, user: user, role: role)
  end
end
