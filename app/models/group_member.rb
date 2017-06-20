class GroupMember < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  ROLES = {
    contributor: 0,
    admin: 1
  }.freeze

  enum role: ROLES

  validates :group, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :group_id }
  validates :role, presence: true
end
