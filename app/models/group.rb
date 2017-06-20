class Group < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :group_members

  def user_role(user)
    group_member = group_members.find { |member| member.user_id == user.id }
    group_member.role if group_member.present?
  end
end
