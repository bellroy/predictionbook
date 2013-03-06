class FeedbackController < ApplicationController
  include ActionView::Helpers::DateHelper
  include DatetimeDescriptionHelper
  
  def show
    date = Prediction.parse_deadline(params[:date])
    render :text => "#{time_in_words_with_context(date)} (i.e. #{date.to_s(:long_ordinal)})" 
  rescue
    render :nothing => true, :status => :bad_request
  end
end
