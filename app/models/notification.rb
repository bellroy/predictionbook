# frozen_string_literal: true

class Notification < ApplicationRecord
  delegate :email_with_name, :has_email?, to: :user
  delegate :description, :deadline, :judged_at, to: :prediction
  delegate :open?, :unknown?, :right?, :wrong?, :due_for_judgement?, :overdue?, :withdrawn?,
           to: :prediction

  belongs_to :prediction
  belongs_to :user

  validates :prediction, presence: true
  validates :user, presence: true, uniqueness: { scope: %i[prediction type] }

  scope :unsent, -> { where(sent: false) }
  scope :sent, -> { where(sent: true) }
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  def initialize(attributes = nil)
    super
    self.uuid ||= UUIDTools::UUID.random_create.to_s
  end

  def use_token!
    update_attribute(:token_used, true)
  end

  def self.use_token!(token)
    dn = find_by(uuid: token)
    if dn.present?
      unless dn.token_used?
        yield dn
        dn.use_token!
      end
    end
  end

  def self.sendable
    unsent.select(&:sendable?)
  end

  def self.send_all!
    # `includes(:prediction, :user)`, eager loading, used to increase efficiency
    # `find_each`, loading records in batches, used to reduce RAM consumption
    default_includes = [{ prediction: %i[judgements creator] }, :user]
    unsent.enabled.includes(default_includes).find_each do |notification|
      notification.deliver! if notification.sendable?
    end
  end

  def sendable?
    false
  end

  def deliver!
    deliver
    update_attribute(:sent, true)
  end
end
