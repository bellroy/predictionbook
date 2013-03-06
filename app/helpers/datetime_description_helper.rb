module DatetimeDescriptionHelper
  def time_in_words_with_context(time)
    time_str = time_ago_in_words(time)
    if time_str.include? "month" or time_str.include? "year"
      # If it's been over a month, return the full date
      "on #{time.strftime("%Y-%m-%d")}"
    elsif time <= Time.now
      "#{time_str} ago"
    else
      "in #{time_str}"
    end
  rescue RangeError,NoMethodError # known issue in Rails
    "on #{time.strftime("%Y-%m-%d")}"
  end
end
