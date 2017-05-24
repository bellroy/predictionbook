class PredictionGroup < ActiveRecord::Base
  has_many :predictions, dependent: :destroy, autosave: true

  validates :description, presence: true

  delegate :deadline_text, :deadline_text=, :notify_creator, :visibility, :group_id,
           to: :default_prediction

  validate :must_have_predictions

  def default_prediction
    predictions.first
  end

  def method_missing(method_id)
    _, index_str, attribute_name = method_id.to_s.match(/prediction_([0-9]?)_(.*)/).to_a
    allowed_method = %w[id description initial_confidence uuid].include?(attribute_name)
    if allowed_method
      prediction = predictions[index_str.to_i]
      prediction.send(attribute_name.to_sym)
    else
      super(method_id)
    end
  end

  private

  def must_have_predictions
    errors.add(:predictions, 'cannot be empty') if predictions.blank?
    predictions.each_with_index do |prediction, index|
      prediction.errors.each do |attribute, message|
        errors.add("prediction_#{index}_#{attribute}".to_sym, message)
      end
    end
  end
end
