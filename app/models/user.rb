# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :responses
  delegate :wagers, to: :responses
  has_many :predictions, through: :responses
  has_many :deadline_notifications
  has_many :response_notifications

  nillify_blank :email, :name

  delegate :image_url, to: :statistics, prefix: true

  validates :login, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                    format: {
                      with: /\A\w[\w\.\-_@]+\z/, message: 'Readable characters only please'
                    }
  validates :name, length: { maximum: 255, allow_nil: true },
                   format: {
                     with: /\A[^[:cntrl:]\\<>\/&]*\z/, message: 'Readable characters only please'
                   }
  validates :email, length: { within: 6..100, allow_nil: true },
                    uniqueness: { case_sensitive: false, allow_nil: true },
                    format: {
                      with: /\A[\w\.%\+\-]+@[-A-Z0-9\._]+\z/i,
                      message: 'does not look like an email address.',
                      allow_nil: true
                    }

  # find by login
  def self.[](login)
    raise(ActiveRecord::RecordNotFound, 'Login is blank') if login.blank?
    find_by_login!(login.gsub('[dot]', '.'))
  end

  def self.generate_api_token
    SecureRandom.urlsafe_base64
  end

  def statistics
    Statistics.new("r.user_id = #{id}")
  end

  def email_with_name
    %("#{self}" <#{email}>)
  end

  def notify_on_overdue?
    has_email?
  end

  def notify_on_judgement?
    has_email?
  end

  def has_email?
    !email.blank?
  end

  def has_overdue_judgements?
    !!predictions.index(&:due_for_judgement?)
  end

  def authorized_for(prediction)
    is_creator = self == prediction.creator
    is_creator || (!prediction.private? && admin?)
  end

  def admin?
    %w[matt gwern].include?(login)
  end

  def to_param
    login.gsub('.', '[dot]')
  end

  def to_s
    name || login
  end

  def remember_me
    remember_me_for 2.years
  end

  def reset_password
    self.password = self.password_confirmation = SecureRandom.hex(6)
    save!

    UserMailer.password_reset(self).deliver
  end

  protected

  # This overrides a Devise method to allow nil emails
  def email_required?
    false
  end
end
