class DeadlineNotification < Notification
  def deliver
    Deliverer.deliver_deadline_notification(self)
  end
 
  def <=>(other)
    deadline <=> other.deadline
  end
 
  def sendable?
    enabled? && has_email? && due_for_judgement? && !withdrawn?
  end
  
  def self.known
    all.reject(&:unknown?)
  end
  
  def self.unknown
    all.select(&:unknown?)
  end
end