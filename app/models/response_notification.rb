class ResponseNotification < Notification
  def deliver
    Deliverer.deliver_response_notification(self)
  end

  def viewed!
    unless new_record?
      update_attributes!(
        :sent => false,
        :token_used => false,
        :new_activity => false)
    end
  end
  
  def new_activity!
    update_attributes!(:new_activity => true)
  end
  
  def sendable?
    enabled? && has_email? && new_activity?
  end
  
end