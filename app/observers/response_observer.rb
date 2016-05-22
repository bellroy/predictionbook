class ResponseObserver < ActiveRecord::Observer
  observe :response

  def after_create(response)
    response.prediction.response_notifications.each(&:new_activity!)
  end
end
