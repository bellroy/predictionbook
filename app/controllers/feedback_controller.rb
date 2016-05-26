class FeedbackController < ApplicationController
  def show
    date = Prediction.parse_deadline(params[:date])
    time_in_words_with_context = TimeInWordsWithContextPresenter.new(date).format
    render text: "#{time_in_words_with_context} (i.e. #{date.to_s(:long_ordinal)})"
  rescue
    render nothing: true, status: :bad_request
  end
end
