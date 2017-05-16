class UpdatedPredictionGroup
  attr_reader :prediction_group

  def initialize(prediction_group, creator, params)
    self.prediction_group = prediction_group
    self.creator = creator
    self.params = params
    update_prediction_group_from_params
    update_predictions_from_params
  end

  private

  attr_accessor :params, :creator
  attr_writer :prediction_group

  delegate :predictions, to: :prediction_group

  def update_prediction_group_from_params
    prediction_group.description = params['description']
  end

  def group_description
    prediction_group.description
  end

  def update_predictions_from_params
    index = 0
    while prediction_description(index).present?
      build_prediction_at_index(index)
      index += 1
    end
  end

  def visibility_attributes
    Visibility.option_to_attributes(params['visibility'])
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
