# frozen_string_literal: true

class TimeInContentTagPresenter
  include ActionView::Helpers::TagHelper

  def initialize(time, css_class = nil)
    self.time = time
    self.css_class = css_class
  end

  def tag
    time_words = TimeInWordsWithContextPresenter.new(time).format
    classes = ['date', css_class].flatten.compact.join(' ')
    content_tag(:span, time_words, title: time.to_s, class: classes)
  end

  private

  attr_accessor :time, :css_class
end
