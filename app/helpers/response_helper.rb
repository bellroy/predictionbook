# encoding: utf-8

module ResponseHelper
  def confidence_for(wager)
    unless wager.confidence.blank?
      confidence_markup = content_tag(:span, "#{wager.confidence}%", 
                                      :class => "confidence", 
                                      :style => style_for_confidence(wager.confidence))
      "estimated #{confidence_markup}".html_safe
    end
  end

  def comment_for(wager)
    if wager.comment?
      if wager.action_comment?
        content_tag(:span, h(wager.action_comment), :class => "action-comment")
      else
        "said “#{content_tag(:span, markup(wager.comment).html_safe, :class => "comment")}”".html_safe
      end
    end
  end
end
