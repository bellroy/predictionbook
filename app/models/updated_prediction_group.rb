# frozen_string_literal: true

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

  def update_prediction_group_from_params
    prediction_group.description = params['description']
  end

  def update_predictions_from_params
    if params['predictions'].present?
      PredictionGroupPredictionsFromNestedParams.new(prediction_group, creator, params).execute
    else
      PredictionGroupPredictionsFromFlatParams.new(prediction_group, creator, params).execute
    end
  end
end
