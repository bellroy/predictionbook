require File.join(Rails.root, "lib/labelled_form_builder")

ActionView::Base.default_form_builder = LabelledFormBuilder
ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| html_tag.to_s }
