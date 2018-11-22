# frozen_string_literal: true

class Group < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :group_members, autosave: true, dependent: :destroy

  before_destroy :make_predictions_private

  def user_role(user)
    group_member = group_members.find { |member| member.user_id == user.id }
    group_member.role if group_member.present?
  end

  def statistics
    Statistics.new("p.visibility = #{Visibility::VALUES[:visible_to_group]} AND p.group_id = #{id}")
  end

  private

  def make_predictions_private
    Prediction
      .visible_to_group.where(group_id: id)
      .update_all(visibility: Visibility::VALUES[:visible_to_creator], group_id: nil)
  end
end
