# frozen_string_literal: true

module Api
  class PredictionGroupByDescriptionController < PredictionGroupsController
    protected

    def find_prediction_group
      scope = PredictionGroup.includes(predictions: %i[responses versions judgements])
      scope.find_or_initialize_by(description: params[:id])
    end
  end
end
