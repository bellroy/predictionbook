module ResponseHelper
  def confidence_for(wager)
    unless wager.confidence.blank?
      "estimated #{content_tag(:span, "#{wager.confidence}%",
        :class => "confidence", :style => style_for_confidence(wager.confidence))}"
    end
  end

  def comment_for(wager)
    if wager.comment?
      if wager.action_comment?
        content_tag(:span, h(wager.action_comment), :class => "action-comment")
      else
        "said “#{content_tag(:span, markup(wager.comment), :class => "comment")}”"
      end
    end
  end
end
