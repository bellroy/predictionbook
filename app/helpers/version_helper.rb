# encoding: utf-8

module VersionHelper
  def changes(version)
    checked_attributes = %w[deadline description withdrawn private]
    previous_attributes = version.previous.attributes
    patch = HashDiff.patch!(version.attributes, previous_attributes).slice(*checked_attributes)
    patch.keys.map { |attr| changed_detail(attr, patch[attr], previous_attributes[attr]) }
  end

  def changed_detail(field, new_value, old_value)
    case field.to_sym
    when :deadline then
      "changed the deadline from “#{TimeInContentTagPresenter.new(old_value).tag}”"
    when :description then
      "changed their prediction from “#{TitleTagPresenter.new(old_value).tag}”"
    when :withdrawn then
      "#{new_value ? 'withdrew' : 'republished'} the prediction"
    when :private then
      "made the prediction #{new_value ? 'private' : 'public'}"
    end
  end
end
