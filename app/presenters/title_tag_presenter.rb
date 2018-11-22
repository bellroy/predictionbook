# frozen_string_literal: true

class TitleTagPresenter
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper

  def initialize(text)
    self.text = text
  end

  def tag
    sanitize textilize_without_paragraph(html_encoded_text), tags: %w[i b em strong u]
  end

  private

  attr_accessor :text

  def html_encoded_text
    # encode tags, not entities
    HTMLEntities.new.encode(text.html_safe, :basic).gsub('&quot;', '"')
  end

  def textilize_without_paragraph(text)
    textiled = textilize(text)
    textiled = textiled[3..-1] if textiled[0..2] == '<p>'
    textiled = textiled[0..-5] if textiled[-4..-1] == '</p>'
    textiled
  end
end
