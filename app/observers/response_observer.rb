# frozen_string_literal: true

class ResponseObserver < ActiveRecord::Observer
  observe :response

  def after_create(response)
    response.prediction.tap do |prediction|
      prediction.response_notifications.each(&:new_activity!)

      tag_adder = TagAdder.new(prediction: response.prediction, string: response.comment)
      if tag_adder.call
        prediction.save
      end
    end
  end
end
