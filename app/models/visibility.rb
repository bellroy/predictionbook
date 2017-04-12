module Visibility
  VALUES = { visible_to_everyone: 0, visible_to_creator: 1 }.freeze

  def self.select_options_html(value)
    VALUES.keys.map do |key|
      key_string = key.to_s
      label = key_string.humanize
      "<option value=\"#{key}\" #{value == key_string ? 'selected' : ''}>#{label}</option>"
    end.join
  end
end
