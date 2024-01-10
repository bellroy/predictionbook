# frozen_string_literal: true

class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :user

  ROLES = {
    contributor: 0,
    admin: 1,
    invitee: 2
  }.freeze

  enum role: ROLES

  validates :group, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :group_id }
  validates :role, presence: true

  after_initialize do
    self.uuid ||= UUIDTools::UUID.random_create.to_s
  end
end
