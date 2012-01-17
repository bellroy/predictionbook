class Prediction < ActiveRecord::Base
  version_fu
  class DuplicateRecord < ActiveRecord::RecordInvalid;end
  include CommonScopes
  belongs_to :creator, :class_name => 'User'
  
  def self.parse_deadline(date)
    Chronic.parse(date, :context => :future)
  end
  
  scope :not_withdrawn, :conditions => { :withdrawn => false }
  # if you change the implementation of 'public', also change this scope in response
  scope :not_private, :conditions => { :private => false }
  def self.unjudged
    not_private.not_withdrawn.all(:include => :judgements,
      :conditions => '(SELECT outcome AS most_recent_outcome FROM judgements WHERE prediction_id = predictions.id ORDER BY created_at DESC LIMIT 1) IS NULL AND deadline < UTC_TIMESTAMP()').
      rsort(:deadline)
  end
  def self.judged
    not_private.not_withdrawn.all(:include => :judgements,
      :conditions => '(SELECT outcome AS most_recent_outcome FROM judgements WHERE prediction_id = predictions.id ORDER BY created_at DESC LIMIT 1) IS NOT NULL',
      :order => 'judgements.created_at DESC')
  end
  def self.future
    sort(:deadline).not_private.not_withdrawn.all(:include => :judgements, :conditions => "judgements.outcome IS NULL AND deadline > UTC_TIMESTAMP()")
  end
  def self.recent
    rsort.not_private.not_withdrawn(:include => [:judgements, :responses, :creator])
  end
  def self.popular
    opts = {
      :include => :responses, # Eager loading of :judgements breaks judgement and unknown?
      :conditions => [
        'predictions.deadline > UTC_TIMESTAMP() AND predictions.created_at > ?', 2.weeks.ago
      ],
      :order => 'count(responses.prediction_id) DESC, predictions.deadline ASC',
      :group => 'predictions.id',
    }
    not_private.not_withdrawn.all(opts).select { |p| p.unknown? }
  end
  
  belongs_to :creator, :class_name => 'User'
  
  has_many :deadline_notifications, :dependent => :destroy
  has_many :response_notifications, :dependent => :destroy
  has_many :judgements,             :dependent => :destroy
  has_many :responses,              :dependent => :destroy
  
  delegate :wagers, :to => :responses
  delegate :comments, :to => :responses
  
  delegate :mean_confidence, :to => :wagers
  
  validates_presence_of :deadline, :message => "When will you know you're right?"
  validates_presence_of :creator, :message => 'Who are you?'
  validates_presence_of :description, :message => 'What are you predicting?'
  validates_presence_of :initial_confidence, :message => 'How sure are you?', :on => :create
  validate :confidence_on_response, :on => :create
  
  after_validation do
    errors.add(:deadline_text, errors[:deadline])
  end
  
  def initialize(attrs = {}, options = {})
    super
    self.uuid ||= UUID.random_create.to_s
    
    if creator and !attrs.include? :private
      self.private = creator.private_default
    end
    
    @initial_response = self.responses.build(
      :prediction => self, 
      :confidence => initial_confidence, 
      :user => creator
    )
    
    deadline_notifications.build(:prediction => self, :user => creator) if notify_creator
  end
  
  def save!
    super
  rescue ActiveRecord::StatementInvalid => error
    raise DuplicateRecord, Prediction.find_by_uuid(uuid) if error.message =~ /Duplicate entry/
    raise
  end
  
  attr_readonly :uuid, :creator_id
  
  attr_accessor :initial_confidence
  
  boolean_accessor_with_default(:notify_creator) {creator ? creator.notify_on_overdue? : false}
  
  # attr_reader :deadline_text
  def deadline_text
    @deadline_text || (deadline ? deadline.localtime.to_s(:db) : "")
  end
  def deadline_text=(new_deadline)
    self[:deadline] = self.class.parse_deadline(new_deadline)
    @deadline_text = new_deadline
  end
  
  def events
    [responses, versions[1..-1], judgements].flatten.sort_by(&:created_at)
  end
  
  def judge!(outcome, user=nil)
    judgements.create!(:user => user, :outcome => outcome)
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
    raise ArgumentError, "Prediction must be open to be withdrawn" unless open?
    update_attribute(:withdrawn, true)
  end
  
  def open?
    !withdrawn? && unknown?
  end
  
  def withdrawable_by?(user)
    open? && creator == user
  end
  
  {:right => true, :wrong => false, :unknown => nil}.each do |name, value|
    define_method :"#{name}?" do
      outcome == value
    end
  end
  
  def due_for_judgement?
    overdue? && unknown?
  end
  
  def overdue?
    deadline < Time.current
  end
  
  def prettied_deadline
    deadline.to_s(:long)
  end
  
  def count_wagers_by(user)
    wagers.count(:conditions => {:user_id => user})
  end
  
  def deadline_notification_for_user(user)
    deadline_notifications.find_by_user_id(user) || deadline_notifications.build(:user => user, :enabled => false)
  end
  
  def response_notification_for_user(user)
    response_notifications.find_by_user_id(user) || response_notifications.build(:user => user, :enabled => false)
  end
  
  def confidence_on_response
    if @initial_response && @initial_response.errors[:confidence]
      errors.add(:initial_confidence, @initial_response.errors[:confidence])
    end
  end
end
