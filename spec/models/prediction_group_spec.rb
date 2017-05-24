require 'spec_helper'

describe PredictionGroup do
  describe '#method_missing' do
    let(:prediction_group) { FactoryGirl.create(:prediction_group, predictions: 3) }

    specify do
      expect(prediction_group.prediction_0_description)
        .to eq prediction_group.predictions[0].description
      expect(prediction_group.prediction_1_description)
        .to eq prediction_group.predictions[1].description
      expect(prediction_group.prediction_2_description)
        .to eq prediction_group.predictions[2].description
    end
  end
end
