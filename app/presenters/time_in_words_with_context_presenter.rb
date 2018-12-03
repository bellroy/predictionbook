# frozen_string_literal: true

class TimeInWordsWithContextPresenter
  include ActionView::Helpers::DateHelper

  def initialize(time)
    self.time = time
    self.ago_in_words = time_ago_in_words(time)
  end

  def format
    default = "on #{time.strftime('%Y-%m-%d')}"
    if ago_in_words.include?('month') || ago_in_words.include?('year')
      # If it's been over a month, return the full date
      default
    elsif time <= Time.zone.now
      "#{ago_in_words} ago"
    else
      "in #{ago_in_words}"
    end
  rescue RangeError, NoMethodError # known issue in Rails
    default
  end

  private

  attr_accessor :time, :ago_in_words
end
