# frozen_string_literal: true

class ResponseObserver < ActiveRecord::Observer
  observe :response

  def after_create(response)
    response.prediction.response_notifications.each(&:new_activity!)
    TagAdder.new(prediction: response.prediction, string: response.comment).call
  end
end
