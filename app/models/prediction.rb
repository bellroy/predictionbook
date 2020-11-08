# frozen_string_literal: true

class Prediction < ApplicationRecord
  # == Constants ============================================================
  DEFAULT_INCLUDES = { judgements: :user, responses: :user, creator: nil, prediction_group: nil,
                       group: nil }.freeze

  # == Attributes ===========================================================
  attr_reader :notify_creator
  attr_readonly :uuid, :creator_id
  attr_writer :initial_confidence

  delegate :comments, to: :responses
  delegate :wagers, to: :responses

  enum visibility: Visibility::VALUES

  # == Extensions ===========================================================
  class DuplicateRecord < ActiveRecord::RecordInvalid; end

  # == Relationships ========================================================
  has_many :deadline_notifications, dependent: :destroy
  has_many :judgements,             dependent: :destroy
  has_many :response_notifications, dependent: :destroy
  has_many :responses,              dependent: :destroy, autosave: true
  has_many :versions, autosave: true, class_name: PredictionVersion.name, dependent: :destroy

  belongs_to :creator, class_name: 'User'
  belongs_to :group
  belongs_to :prediction_group

  # == Validations ==========================================================
  validates :description, length: { maximum: 255, message: 'Keep your description under 255 characters in length' }
  validates :deadline, presence: { message: "When will you know you're right?" }
  validates :creator, presence: { message: 'Who are you?' }
  validates :description, presence: { message: 'What are you predicting?' }
  validates :initial_confidence, presence: { message: 'How sure are you?', on: :create }
  validate :confidence_on_response, on: :create
  validate :bound_deadline

  # == Scopes ===============================================================
  scope :not_withdrawn, -> { where(withdrawn: false) }

  # == Callbacks ============================================================
  after_initialize do
    self.uuid ||= UUIDTools::UUID.random_create.to_s if has_attribute?(:uuid)
  end

  before_validation(on: :create) do
    @initial_response ||= responses.build(prediction: self, confidence: initial_confidence,
                                          user: creator)

    deadline_notifications.build(prediction: self, user: creator) if notify_creator
  end

  after_validation do
    errors.add(:deadline_text, errors[:deadline])
  end

  before_save :create_version_if_required
  after_save :synchronise_group_visibility_and_deadline

  # == Class Methods ========================================================
  def self.parse_deadline(date)
    Chronic.parse(date, context: :future)
  end

  def self.unjudged
    not_withdrawn
      .includes(DEFAULT_INCLUDES)
      .where('(SELECT outcome AS most_recent_outcome FROM judgements WHERE prediction_id = predictions.id ORDER BY created_at DESC LIMIT 1) IS NULL AND deadline < CURRENT_TIMESTAMP')
      .order(deadline: :desc)
  end

  def self.judged
    not_withdrawn
      .includes(DEFAULT_INCLUDES)
      .joins(:judgements)
      .where('(SELECT outcome AS most_recent_outcome FROM judgements WHERE prediction_id = predictions.id ORDER BY created_at DESC LIMIT 1) IS NOT NULL')
      .order('judgements.created_at DESC')
  end

  def self.future
    not_withdrawn
      .includes(DEFAULT_INCLUDES)
      .where('(id NOT IN (SELECT prediction_id FROM judgements) OR id IN (SELECT prediction_id FROM judgements WHERE outcome IS NULL)) AND deadline > CURRENT_TIMESTAMP')
      .order(:deadline)
  end

  def self.recent
    order(created_at: :desc).not_withdrawn.includes(DEFAULT_INCLUDES)
  end

  def self.popular
    visible_to_everyone
      .not_withdrawn
      .includes(DEFAULT_INCLUDES)
      .joins(:responses)
      .where('predictions.deadline > CURRENT_TIMESTAMP AND predictions.created_at > ?', 2.weeks.ago)
      .where('predictions.id NOT IN (SELECT prediction_id FROM judgements WHERE outcome IS NOT NULL)')
      .order(Arel.sql('count(responses.prediction_id) DESC, predictions.deadline ASC'))
      .group('predictions.id')
  end

  # == Instance Methods =====================================================

  def create_version_if_required
    PredictionVersion.create_from_current_prediction_if_required(self)
    true # Never halt save
  end

  def initialize(attributes = nil)
    notify_creator_bool = extract_notify_creator_bool(attributes)
    super
    assign_notify_creator_with_default(notify_creator_bool)
  end

  def assign_attributes(attributes)
    notify_creator_bool = extract_notify_creator_bool(attributes)
    super
    assign_notify_creator_with_default(notify_creator_bool)
  end

  def save!
    super
  rescue ActiveRecord::RecordNotUnique => error
    if error.message.match?(/index_predictions_on_uuid/)
      raise DuplicateRecord, Prediction.find_by(uuid: uuid)
    end

    raise
  end

  def initial_confidence
    @initial_confidence || responses.first.try(:confidence)
  end

  def deadline_text
    @deadline_text || (deadline ? deadline.localtime.to_s(:db) : '')
  end

  def deadline_text=(new_deadline)
    self[:deadline] = self.class.parse_deadline(new_deadline)
    @deadline_text = new_deadline
  end

  def preloaded_wagers
    responses.select(&:confidence)
  end

  def preloaded_comments
    responses.select(&:comment)
  end

  def mean_confidence
    if !preloaded_wagers.empty?
      total = preloaded_wagers.map(&:confidence).inject(0, &:+)
      (total / preloaded_wagers.length).round
    else
      0
    end
  end

  def events
    [responses, versions[1..-1], judgements].flatten.sort_by(&:created_at)
  end

  def judge!(outcome, user = nil)
    judgements.create!(user: user, outcome: outcome)
  end

  def judgement
    judgements.last
  end

  def judgement?
    !judgement.worthless? if judgement
  end

  def outcome
    judgement&.outcome
  end

  def judged_at
    judgement&.created_at
  end

  def readable_outcome
    if withdrawn?
      'withdrawn'
    elsif judgement
      judgement.outcome_in_words
    end
  end

  def wager_count
    wagers.size
  end

  def withdraw!
    raise ArgumentError, 'Prediction must be open to be withdrawn' unless open?

    update_attribute(:withdrawn, true)
  end

  def open?
    !withdrawn? && unknown?
  end

  def withdrawable_by?(user)
    open? && creator == user
  end

  { right: true, wrong: false, unknown: nil }.each do |name, value|
    define_method :"#{name}?" do
      outcome == value
    end
  end

  def due_for_judgement?
    !withdrawn? && overdue? && unknown?
  end

  def overdue?
    deadline < Time.current
  end

  def prettied_deadline
    deadline.to_s(:long)
  end

  def count_wagers_by(user)
    wagers.where(user_id: user.id).count
  end

  def deadline_notification_for_user(user)
    deadline_notifications.find_by(user_id: user) || deadline_notifications.build(user: user, enabled: false)
  end

  def response_notification_for_user(user)
    response_notifications.find_by(user_id: user) || response_notifications.build(user: user, enabled: false)
  end

  def confidence_on_response
    if @initial_response && @initial_response.errors[:confidence]
      errors.add(:initial_confidence, @initial_response.errors[:confidence])
    end
  end

  def bound_deadline
    if too_futuristic?
      errors.add(:deadline, 'Please consider creating a time capsule to record this prediction.')
    elsif before_christ?
      errors.add(:deadline, "If it was known that long ago, it's not exactly a prediction, is it?")
    elsif retrodiction?
      errors.add(:deadline, "Please don't make 'predictions' about the past. This isn't 'RetrodictionBook'.")
    end
  end

  def description_with_group
    tokens = []
    tokens << "[#{prediction_group.description}]" if prediction_group_id.present?
    tokens << description
    tokens.join(' ')
  end

  def creator=(value)
    super
    assign_notify_creator_with_default(nil) unless notify_creator_set_by_attributes
  end

  private

  attr_writer :notify_creator
  attr_accessor :notify_creator_set_by_attributes

  def too_futuristic?
    return deadline.year > 9999 unless deadline.nil?

    false
  end

  def before_christ?
    return deadline.year < 1 unless deadline.nil?

    false
  end

  def retrodiction?
    return deadline < Time.zone.now - 15.days unless deadline.nil?

    false
  end

  def synchronise_group_visibility_and_deadline
    return if prediction_group_id.blank?

    vis_int = Visibility::VALUES[visibility.to_sym]
    predictions_in_group = Prediction.where(prediction_group_id: prediction_group_id)
    predictions_in_group.update_all(deadline: deadline, visibility: vis_int, group_id: group_id)
  end

  def extract_notify_creator_bool(attributes)
    notify_creator_value = attributes.delete(:notify_creator) if attributes.present?
    [true, 'true', 1, '1', 't'].include?(notify_creator_value) unless notify_creator_value.nil?
  end

  def assign_notify_creator_with_default(notify_creator_bool)
    if notify_creator_bool.nil?
      self.notify_creator = creator&.notify_on_overdue? || false
    else
      self.notify_creator = notify_creator_bool
      self.notify_creator_set_by_attributes = true
    end
  end
end
