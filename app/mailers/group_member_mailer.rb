# frozen_string_literal: true

class GroupMemberMailer < ApplicationMailer
  def invitation(group_member)
    @uuid = group_member.uuid
    @group = group_member.group
    @user = group_member.user

    mail(subject: "[PredictionBook] Invitation to join ‘#{@group.name}’ user group",
         to: @user.email)
  end

  def ejection(group_member)
    @group = group_member.group
    @user = group_member.user

    mail(subject: "[PredictionBook] Ejection from ‘#{@group.name}’ user group",
         to: @user.email)
  end
end
