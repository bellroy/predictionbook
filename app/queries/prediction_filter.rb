# frozen_string_literal: true

module PredictionFilter
  def self.filter(user, current_user, filter, page)
    predictions = user.predictions
    predictions = predictions.visible_to_everyone unless current_user == user

    # Since these methods from Prediction only filter visible_to_everyone
    # predictions, self.filter won't include private predictions.
    # TODO: improve Prediction's methods

    predictions =
      case filter
      when 'judged' then predictions.judged
      when 'unjudged' then predictions.unjudged
      when 'future' then predictions.future
      else predictions
      end

    predictions.page(page)
  end
end
