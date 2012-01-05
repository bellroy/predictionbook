module VersionHelper
  def changes(version)
    result = []
    checked_attributes = %w(deadline description withdrawn private)
    previous_attributes = version.previous.attributes
    version.attributes.diff(previous_attributes).slice(*checked_attributes).each do |attr, value|
      result << changed_detail(attr, value, previous_attributes[attr])
    end
    result
  end
  
  def changed_detail(field, new_value, old_value)
    case field.to_sym
    when :deadline then
      "changed the deadline from “#{show_time(old_value)}”"
    when :description then
      "changed their prediction from “#{show_title(old_value)}”"
    when :withdrawn then
      "#{new_value ? 'withdrew' : 'republished' } the prediction"
    when :private then
      "made the prediction #{new_value ? 'private' : 'public'}"
    end
  end
  
end