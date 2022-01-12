# frozen_string_literal: true

module PredictionFilter
  def self.filter(user, current_user, filter, page)
    predictions = user.predictions
    predictions = predictions.visible_to_everyone unless current_user == user

    PredictionsQuery.new(page: page, predictions: predictions, status: filter).call
  end
end
