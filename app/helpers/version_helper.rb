# encoding: utf-8

module VersionHelper
  def changes(version)
    previous_version = version.previous_version
    return [] if previous_version.nil?
    prev_attrs = previous_version.attributes
    columns = PredictionVersion.versioned_prediction_columns.map(&:to_s)
    raw_diff = HashDiff.diff(prev_attrs, version.attributes)
    diff = raw_diff.select { |array| columns.include?(array[1]) }
    diff.map { |array| changed_detail(array[1], array[3], array[2]) }
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
