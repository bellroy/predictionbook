require 'spec_helper'

describe UpdatedPredictionGroup do
  let(:updated_prediction_group) { described_class.new(prediction_group, user, params) }
  let(:user) { FactoryGirl.create(:user) }
  let(:prediction_group) { PredictionGroup.new }
  let(:params) do
    HashWithIndifferentAccess.new(
      description: 'This will happen tomorrow',
      visibility: 'visible_to_group_1',
      deadline_text: '2 days from now',
      prediction_0_description: 'AIDS',
      prediction_0_initial_confidence: 1,
      prediction_1_description: 'War',
      prediction_1_initial_confidence: 15,
      prediction_2_description: 'Famine',
      prediction_2_initial_confidence: 85
    )
  end

  describe '#prediction_group' do
    subject(:new_group) { updated_prediction_group.prediction_group }

    specify do
      expect(new_group.description).to eq 'This will happen tomorrow'
      first_prediction = new_group.predictions[0]
      expect(first_prediction.description_with_group).to eq 'AIDS'
      expect(first_prediction.initial_confidence).to eq 1
      expect(first_prediction.deadline).to be > 47.hours.from_now
      expect(first_prediction.visibility).to eq 'visible_to_group'
      expect(first_prediction.group_id).to eq 1

      second_prediction = new_group.predictions[1]
      expect(second_prediction.description_with_group).to eq 'War'
      expect(second_prediction.initial_confidence).to eq 15
      expect(second_prediction.deadline).to be > 47.hours.from_now
      expect(second_prediction.visibility).to eq 'visible_to_group'
      expect(second_prediction.group_id).to eq 1

      third_prediction = new_group.predictions[2]
      expect(third_prediction.description_with_group).to eq 'Famine'
      expect(third_prediction.initial_confidence).to eq 85
      expect(third_prediction.deadline).to be > 47.hours.from_now
      expect(third_prediction.visibility).to eq 'visible_to_group'
      expect(third_prediction.group_id).to eq 1
    end
  end
end
