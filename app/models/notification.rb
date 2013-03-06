class Notification < ActiveRecord::Base
  delegate :email_with_name, :has_email?, :to => :user
  delegate :description, :deadline, :judged_at, :to => :prediction
  delegate :open?, :unknown?, :right?, :wrong?, :due_for_judgement?, :overdue?, :withdrawn?, :to => :prediction

  belongs_to :prediction
  belongs_to :user

  validates_presence_of :user
  validates_presence_of :prediction
  
  validates_uniqueness_of :user_id, :scope => [:prediction_id, :type]
  
  scope :unsent, :conditions => {:sent => false}
  scope :sent,   :conditions => {:sent => true}
  scope :enabled,   :conditions => {:enabled => true}
  scope :disabled,  :conditions => {:enabled => false}
  
  def initialize(attrs = {}, options = {})
    super
    self.uuid ||= UUID.random_create.to_s
  end
  
  def use_token!
    update_attribute(:token_used, true)
  end
  
  def self.use_token!(token)
    if dn = find_by_uuid(token)
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
    sendable.each do |notification|
      notification.deliver!
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
