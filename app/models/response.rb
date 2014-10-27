class Response < ActiveRecord::Base
  include CommonScopes

  include ActionView::Helpers::SanitizeHelper

  belongs_to :prediction
  belongs_to :user

  MAX_COMMENT_LENGTH = 250

  validates_presence_of :prediction
  validates_presence_of :user, :message => 'Who are you?'
  validates_inclusion_of :confidence, :in => 0..100, :allow_nil => true, :message => 'a probability is between 0 and 100%'
  validate :length_of_comment_maximum, :if => lambda { |response| response.comment? }
  validate :presence_of_either_confidence_or_comment
  validate :prediction_accepting_confidences

  delegate :unknown?, :to => :prediction
  scope :comments, :conditions => "comment is not null"

  nillify_blank :comment

  WAGER_CONDITION = "confidence is not null"
  scope :wagers, :conditions => WAGER_CONDITION do
    def predictions
      collect(&:prediction).uniq
    end
    def statistics
      Statistics.new(self)
    end
    def mean_confidence
      average(:confidence).round unless empty?
    end
  end

  scope :not_private,
    :joins => :prediction,
    :conditions => {'predictions.private' => false}

  def self.recent
    rsort.not_private.prefetch_joins
  end

  def self.prefetch_joins
    all(:include => [:user, :prediction => [:judgements, :responses]])
  end

  def agree?
    confidence ? confidence >= 50 : true
  end

  def relative_confidence
    agree? ? confidence : 100 - confidence
  end

  def correct?
    if unknown?
      return
    else
      (prediction.right? and agree?) or (!prediction.right? and !agree?)
    end
  end

  def comment
    CleanCloth.new(self[:comment]) if comment?
  end

  def action_comment?
    comment? && comment.starts_with?('/me ') && !action_comment.blank?
  end

  def action_comment
    comment.sub(/^\/me /,'').strip() if comment?
  end

  def text_only_comment
    comment? ? sanitize(comment.to_html, :tags => []) : ""
  end

  def characters_left
    MAX_COMMENT_LENGTH - text_only_comment.length
  end

private
  def length_of_comment_maximum
    errors.add(:comment, "must be less than #{MAX_COMMENT_LENGTH} characters") unless characters_left > 0
  end

  def presence_of_either_confidence_or_comment
    if confidence.blank? && comment.blank?
      errors.add(:confidence, "confidence or comment is required")
      errors.add(:comment, "comment or confidence is required")
    end
  end

  def prediction_accepting_confidences
    unless prediction.blank? || prediction.unknown? || confidence.blank?
      errors.add(:prediction, 'Prediction outcome already determined')
    end
  end
end
