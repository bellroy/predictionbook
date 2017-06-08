class Prediction < ActiveRecord::Base
  has_many :versions, autosave: true, class_name: PredictionVersion

  belongs_to :group
  belongs_to :prediction_group

  enum visibility: Visibility::VALUES

  before_save :create_version_if_required
  after_save :synchronise_group_visibility_and_deadline

  def create_version_if_required
    PredictionVersion.create_from_current_prediction_if_required(self)
    true # Never halt save
  end

  class DuplicateRecord < ActiveRecord::RecordInvalid; end

  belongs_to :creator, class_name: 'User'

  def self.parse_deadline(date)
    Chronic.parse(date, context: :future)
  end

  scope :not_withdrawn, -> { where(withdrawn: false) }

  DEFAULT_INCLUDES = %i[judgements responses creator prediction_group].freeze

  def self.unjudged
    visible_to_everyone
      .not_withdrawn
      .includes(DEFAULT_INCLUDES)
      .where('(SELECT outcome AS most_recent_outcome FROM judgements WHERE prediction_id = predictions.id ORDER BY created_at DESC LIMIT 1) IS NULL AND deadline < UTC_TIMESTAMP()')
      .order(deadline: :desc)
  end

  def self.judged
    visible_to_everyone
      .not_withdrawn
      .includes(DEFAULT_INCLUDES)
      .joins(:judgements)
      .where('(SELECT outcome AS most_recent_outcome FROM judgements WHERE prediction_id = predictions.id ORDER BY created_at DESC LIMIT 1) IS NOT NULL')
      .order('judgements.created_at DESC')
  end

  def self.future
    visible_to_everyone
      .not_withdrawn
      .includes(DEFAULT_INCLUDES)
      .where('(id NOT IN (SELECT prediction_id FROM judgements) OR id IN (SELECT prediction_id FROM judgements WHERE outcome IS NULL)) AND deadline > UTC_TIMESTAMP()')
      .order(:deadline)
  end

  def self.recent
    order(created_at: :desc).visible_to_everyone.not_withdrawn.includes(DEFAULT_INCLUDES)
  end

  def self.popular
    visible_to_everyone
      .not_withdrawn
      .includes(:responses, :creator)
      .joins(:responses)
      .where('predictions.deadline > UTC_TIMESTAMP() AND predictions.created_at > ?', 2.weeks.ago)
      .where('predictions.id NOT IN (SELECT prediction_id FROM judgements WHERE outcome IS NOT NULL)')
      .order('count(responses.prediction_id) DESC, predictions.deadline ASC')
      .group('predictions.id')
  end

  belongs_to :creator, class_name: 'User'

  has_many :deadline_notifications, dependent: :destroy
  has_many :response_notifications, dependent: :destroy
  has_many :judgements,             dependent: :destroy
  has_many :responses,              dependent: :destroy, autosave: true

  delegate :wagers, to: :responses
  delegate :comments, to: :responses

  validates_presence_of :deadline, message: "When will you know you're right?"
  validates_presence_of :creator, message: 'Who are you?'
  validates_presence_of :description, message: 'What are you predicting?'
  validates_presence_of :initial_confidence, message: 'How sure are you?', on: :create
  validate :confidence_on_response, on: :create
  validate :bound_deadline

  after_validation do
    errors.add(:deadline_text, errors[:deadline])
  end

  after_initialize do
    self.uuid ||= UUIDTools::UUID.random_create.to_s if has_attribute?(:uuid)
  end

  before_validation(on: :create) do
    @initial_response ||= responses.build(
      prediction: self,
      confidence: initial_confidence,
      user: creator
    )

    deadline_notifications.build(prediction: self, user: creator) if notify_creator
  end

  def save!
    super
  rescue ActiveRecord::StatementInvalid => error
    raise DuplicateRecord, Prediction.find_by(uuid: uuid) if error.message =~ /Duplicate entry/
    raise
  end

  attr_readonly :uuid, :creator_id

  def initial_confidence
    @initial_confidence || responses.first.try(:confidence)
  end

  def initial_confidence=(value)
    @initial_confidence = value
  end

  boolean_accessor_with_default(:notify_creator) { creator ? creator.notify_on_overdue? : false }

  # attr_reader :deadline_text
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
    judgement.outcome if judgement
  end

  def judged_at
    judgement.created_at if judgement
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
    result = ''
    result << "[#{prediction_group.description}] " if prediction_group_id.present?
    result << description
  end

  private

  def too_futuristic?
    return deadline.year > 9999 unless deadline.nil?
    false
  end

  def before_christ?
    return deadline.year < 1 unless deadline.nil?
    false
  end

  def retrodiction?
    return deadline < Time.now - 15.days unless deadline.nil?
    false
  end

  def synchronise_group_visibility_and_deadline
    return if prediction_group_id.blank?
    vis_int = Visibility::VALUES[visibility.to_sym]
    predictions_in_group = Prediction.where(prediction_group_id: prediction_group_id)
    predictions_in_group.update_all(deadline: deadline, visibility: vis_int, group_id: group_id)
  end
end
