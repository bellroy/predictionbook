module Visibility
  VALUES = { visible_to_everyone: 0, visible_to_creator: 1, visible_to_group: 2 }.freeze

  def self.select_options_html(groups, current_visibility, current_group_id)
    non_group_options = (VALUES.keys - [:visible_to_group]).map do |key|
      key_string = key.to_s
      label = key_string.humanize
      "<option value=\"#{key}\" #{current_visibility == key_string ? 'selected' : ''}>#{label}</option>"
    end.join

    group_options = groups.map do |group|
      group_id = group.id
      key = "visible_to_group_#{group_id}"
      label = "Visible to #{group.name} group"
      selected = current_visibility == 'visible_to_group' && current_group_id == group_id
      "<option value=\"#{key}\" #{selected ? 'selected' : ''}>#{label}</option>"
    end.join

    non_group_options + group_options
  end

  def self.option_to_attributes(option)
    if option.starts_with?('visible_to_group_')
      { visibility: 'visible_to_group', group_id: option.gsub('visible_to_group_', '').to_i }
    else
      { visibility: option, group_id: nil }
    end
  end
end
