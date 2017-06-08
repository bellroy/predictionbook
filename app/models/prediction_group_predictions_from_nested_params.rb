class PredictionGroupPredictionsFromNestedParams
  def initialize(prediction_group, creator, params)
    self.prediction_group = prediction_group
    self.creator = creator
    self.params = params
  end

  def execute
    (params['predictions'] || []).each do |prediction_hash|
      prediction_attrs = prediction_hash['prediction'].dup
      prediction_attrs['creator'] ||= creator
      build_prediction_from_attrs(prediction_attrs)
    end
  end

  private

  attr_accessor :prediction_group, :params, :creator

  delegate :predictions, to: :prediction_group

  def build_prediction_from_attrs(prediction_attrs)
    prediction = prediction_for_id(prediction_attrs.delete('id'))
    responses = prediction_attrs.delete('responses')
    prediction.assign_attributes(prediction_attrs)
    responses.each do |response_hash|
      response_attrs = response_hash['response'].dup
      response = response_for_id(prediction, response_attrs.delete('id'))
      response_attrs.delete('prediction_id')
      response.assign_attributes(response_attrs)
    end
  end

  def prediction_for_id(id)
    prediction = predictions.find { |pred| pred.id.to_s == id.to_s }
    if prediction.nil? || prediction.id < 1
      prediction = Prediction.new(prediction_group: prediction_group)
      predictions << prediction
    end
    prediction
  end

  def response_for_id(prediction, id)
    responses = prediction.responses
    response = responses.find { |resp| resp.id.to_s == id.to_s }
    if response.nil? || response.id < 1
      response = Response.new(prediction: prediction)
      responses << response
    end
    response
  end
end
