# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
         :validatable, :confirmable

  has_many :responses, dependent: :destroy
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  delegate :wagers, to: :responses
  has_many :deadline_notifications, dependent: :destroy
  has_many :response_notifications, dependent: :destroy
  has_one :credence_game, dependent: :destroy
  has_many :judgements, dependent: :destroy
  has_many :predictions, dependent: :destroy, foreign_key: :creator_id

  nillify_blank :email, :name

  enum visibility_default: Visibility::VALUES

  delegate :image_url, to: :statistics, prefix: true

  validates :login, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                    format: {
                      with: /\A\w[\w\.\-_@]+\z/, message: 'Readable characters only please'
                    }
  validates :name, length: { maximum: 255, allow_nil: true },
                   format: {
                     with: /\A[^[:cntrl:]\\<>\/&]*\z/, message: 'Readable characters only please'
                   }
  validates :email, presence: true, length: { within: 6..100, allow_nil: true },
                    uniqueness: { case_sensitive: false, allow_nil: true },
                    format: {
                      with: /\A[\w\.%\+\-]+@[-A-Z0-9\._]+\z/i,
                      message: 'does not look like an email address.',
                      allow_nil: true
                    }

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    conditions_hash = conditions.to_hash
    if login.present?
      where(conditions_hash)
        .find_by(['lower(login) = :value OR lower(email) = :value', { value: login.downcase }])
    elsif conditions.key?(:login) || conditions.key?(:email)
      find_by(conditions_hash)
    end
  end

  def self.generate_api_token
    SecureRandom.urlsafe_base64
  end

  def predictions
    prediction_ids = wagers.select(:prediction_id).map(&:prediction_id)
    Prediction.where(id: prediction_ids).order(updated_at: :desc)
  end

  def devise_password_specified?
    encrypted_password.present?
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
    email.present?
  end

  def has_overdue_judgements?
    !!predictions.index(&:due_for_judgement?)
  end

  def authorized_for?(prediction, action = 'show')
    is_creator = self == prediction.creator
    user_group = groups.find { |ug| ug.id == prediction.group_id }
    user_group_role = user_group.user_role(self) if user_group.present?
    return true if is_creator || admin? || user_group_role == 'admin'
    return false unless %w[index show].include?(action)

    prediction.visible_to_everyone? || (prediction.visible_to_group? && user_group.present?)
  end

  def to_param
    (login || '').gsub('.', '[dot]')
  end

  def to_s
    name || login
  end

  def valid_password?(password)
    crypted_password.present? && old_password_digest(password, salt) == crypted_password ||
      Devise::Encryptor.compare(self.class, encrypted_password, password)
  end

  protected

  def old_password_digest(password, salt)
    digest = REST_AUTH_SITE_KEY
    REST_AUTH_DIGEST_STRETCHES.times do
      digest = old_secure_digest(digest, salt, password, REST_AUTH_SITE_KEY)
    end
    digest
  end

  def old_secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end
end
