class Response < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  belongs_to :prediction
  belongs_to :user

  MAX_COMMENT_LENGTH = 250

  validates :prediction, presence: true
  validates :user, presence: { message: 'Who are you?' }
  validates :confidence, inclusion: { in: 0..100, message: 'a probability is between 0 and 100%' },
                         allow_nil: true
  validate :length_of_comment_maximum, if: ->(response) { response.comment? }
  validate :presence_of_either_confidence_or_comment
  validate :prediction_accepting_confidences

  delegate :unknown?, to: :prediction
  scope :comments, -> { where('comment is not null') }

  nillify_blank :comment

  WAGER_CONDITION = 'confidence is not null'.freeze
  scope :wagers, -> { where(WAGER_CONDITION) }

  scope :not_private, -> { joins(:prediction).where(predictions: { private: false }) }

  def self.recent(limit: 100)
    order(created_at: :desc).not_private.prefetch_joins.limit(limit)
  end

  def self.prefetch_joins
    includes(user: { responses: { prediction: [:judgements, :responses] } })
  end

  def self.predictions
    collect(&:prediction).uniq
  end

  def self.mean_confidence
    average(:confidence).round unless count == 0
  end

  def agree?
    confidence ? confidence >= 50 : true
  end

  def relative_confidence
    agree? ? confidence : 100 - confidence
  end

  def correct?
    return if unknown?
    correct_prediction = prediction.right?
    (correct_prediction && agree?) || (!correct_prediction && !agree?)
  end

  def comment
    CleanCloth.new(self[:comment]) if comment?
  end

  def action_comment?
    comment? && comment.starts_with?('/me ') && !action_comment.blank?
  end

  def action_comment
    comment.sub(/^\/me /, '').strip if comment?
  end

  def text_only_comment
    comment? ? sanitize(comment.to_html, tags: []) : ''
  end

  def characters_left
    MAX_COMMENT_LENGTH - text_only_comment.length
  end

  private

  def length_of_comment_maximum
    errors.add(:comment,
               "must be less than #{MAX_COMMENT_LENGTH} characters") unless characters_left > 0
  end

  def presence_of_either_confidence_or_comment
    if confidence.blank? && comment.blank?
      errors.add(:confidence, 'confidence or comment is required')
      errors.add(:comment, 'comment or confidence is required')
    end
  end

  def prediction_accepting_confidences
    unless prediction.blank? || prediction.unknown? || confidence.blank?
      errors.add(:prediction, 'Prediction outcome already determined')
    end
  end
end
