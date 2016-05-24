class PredictionVersion < ActiveRecord::Base
  belongs_to :prediction

  def self.create_from_current_prediction_if_required(prediction)
    return unless new_version_required?(prediction)
    new_version = prediction.versions.build
    versioned_prediction_columns.each do |attribute|
      new_version.send "#{attribute}=".to_sym, prediction.send(attribute)
    end
    version_number = prediction.new_record? ? 1 : prediction.version + 1
    new_version.version = version_number
    prediction.version = version_number
  end

  def self.versioned_prediction_columns
    [:description, :deadline, :withdrawn, :private]
  end

  def self.new_version_required?(prediction)
    versioned_prediction_columns.detect { |attrib| prediction.send "#{attrib}_changed?".to_sym }
  end

  def previous_version
    return nil if version == 1
    prediction.versions.where('version < ?', version).order(version: :desc).first
  end
end
