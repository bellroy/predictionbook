# frozen_string_literal: true

module ResponseHelper
  def confidence_for(wager)
    confidence = wager.confidence
    if confidence.present?
      confidence_markup = content_tag(:span, "#{confidence}%",
                                      class: 'confidence',
                                      style: style_for_confidence(confidence))
      "estimated #{confidence_markup}".html_safe
    end
  end

  def comment_for(wager)
    return nil unless wager.comment?

    action_comment = wager.action_comment?
    return content_tag(:span, h(wager.action_comment), class: 'action-comment') if action_comment

    "said “#{content_tag(:span, markup(wager.comment).html_safe, class: 'comment')}”".html_safe
  end
end
