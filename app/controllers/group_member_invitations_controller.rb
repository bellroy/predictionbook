# frozen_string_literal: true

class GroupMemberInvitationsController < ApplicationController
  def show
    group_member = GroupMember.includes(:group).find_by(uuid: params[:id])
    if group_member.nil? || !group_member.invitee?
      redirect_to(root_url)
      return
    end
    group_member.update_attributes(role: 'contributor')
    group = group_member.group
    redirect_to(root_url, notice: "You are now a contributing member of the #{group.name} group")
  end
end
