class PredictionGroupPredictionsFromFlatParams
  def initialize(prediction_group, creator, params)
    self.prediction_group = prediction_group
    self.creator = creator
    self.params = params
  end

  def execute
    index = 0
    while prediction_description(index).present?
      build_prediction_at_index(index)
      index += 1
    end
  end

  private

  attr_accessor :prediction_group, :params, :creator

  delegate :predictions, to: :prediction_group

  def visibility_attributes
    visibility_params = params['visibility']
    if visibility_params.present?
      Visibility.option_to_attributes(visibility_params)
    else
      { visibility: creator.visibility_default, group_id: creator.group_default_id }
    end
  end

  def deadline_text
    params['deadline_text']
  end

  def prediction_id(index)
    params["prediction_#{index}_id"]
  end

  def prediction_description(index)
    params["prediction_#{index}_description"]
  end

  def prediction_initial_confidence(index)
    params["prediction_#{index}_initial_confidence"]
  end

  def prediction_uuid(index)
    params["prediction_#{index}_uuid"]
  end

  def existing_prediction_matching(index)
    id = prediction_id(index)
    return nil if id.blank?
    predictions.find { |pred| pred.id.to_s == id }
  end

  def build_prediction_at_index(index)
    match = existing_prediction_matching(index) || predictions.new
    match.assign_attributes(prediction_attributes(index))
  end

  def prediction_attributes(index)
    {
      description: prediction_description(index),
      initial_confidence: prediction_initial_confidence(index),
      visibility: visibility_attributes[:visibility],
      group_id: visibility_attributes[:group_id],
      uuid: prediction_uuid(index),
      creator: creator,
      deadline_text: deadline_text
    }
  end
end
