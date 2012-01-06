class ResponseObserver < ActiveRecord::Observer
  observe :response
  
  def after_create(response)
    response.prediction.response_notifications.each do |notification|
      notification.new_activity!
    end
  end
end