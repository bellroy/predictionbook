# frozen_string_literal: true

module PredictionFilter
  def self.filter(user, current_user, filter, page)
    predictions = user.predictions
    predictions = predictions.visible_to_everyone unless current_user == user

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
