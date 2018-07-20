# frozen_string_literal: true

require 'spec_helper'

describe UpdatedPredictionGroup do
  let(:updated_prediction_group) { described_class.new(prediction_group, user, params) }
  let(:user) { FactoryBot.create(:user) }
  let(:prediction_group) { PredictionGroup.new }
  let(:group) { FactoryBot.create(:group) }
  let(:params) do
    HashWithIndifferentAccess.new(
      description: 'This will happen tomorrow',
      visibility: "visible_to_group_#{group.id}",
      deadline_text: '2 days from now',
      notify_creator: false,
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

    context 'flat param structure' do
      specify do
        new_group.save!
        expect(PredictionGroup.count).to eq 1
        expect(Prediction.count).to eq 3
        expect(Response.count).to eq 3

        expect(new_group.description).to eq 'This will happen tomorrow'
        first_prediction = new_group.predictions[0]
        expect(first_prediction.description_with_group).to eq '[This will happen tomorrow] AIDS'
        expect(first_prediction.initial_confidence).to eq 1
        expect(first_prediction.deadline).to be > 47.hours.from_now
        expect(first_prediction.visibility).to eq 'visible_to_group'
        expect(first_prediction.group_id).to eq group.id
        expect(first_prediction.deadline_notifications.count).to eq 0

        second_prediction = new_group.predictions[1]
        expect(second_prediction.description_with_group).to eq '[This will happen tomorrow] War'
        expect(second_prediction.initial_confidence).to eq 15
        expect(second_prediction.deadline).to be > 47.hours.from_now
        expect(second_prediction.visibility).to eq 'visible_to_group'
        expect(second_prediction.group_id).to eq group.id
        expect(second_prediction.deadline_notifications.count).to eq 0

        third_prediction = new_group.predictions[2]
        expect(third_prediction.description_with_group).to eq '[This will happen tomorrow] Famine'
        expect(third_prediction.initial_confidence).to eq 85
        expect(third_prediction.deadline).to be > 47.hours.from_now
        expect(third_prediction.visibility).to eq 'visible_to_group'
        expect(third_prediction.group_id).to eq group.id
        expect(third_prediction.deadline_notifications.count).to eq 0
      end
    end

    context 'nested object structure' do
      let(:params) do
        HashWithIndifferentAccess.new(
          id: '0',
          description: 'This will happen tomorrow',
          predictions: [
            {
              prediction: HashWithIndifferentAccess.new(
                id: '0',
                description: 'AIDS',
                deadline: 2.days.from_now.strftime('%Y-%m-%d %H:%M'),
                visibility: Visibility::VALUES[:visible_to_group],
                group_id: group.id,
                notify_creator: false,
                responses: [{ response: { id: '0', confidence: 1, user_id: user.id } }]
              )
            },
            {
              prediction: HashWithIndifferentAccess.new(
                id: '0',
                description: 'War',
                deadline: 2.days.from_now.strftime('%Y-%m-%d %H:%M'),
                visibility: Visibility::VALUES[:visible_to_group],
                group_id: group.id,
                notify_creator: true,
                responses: [{ response: { id: '0', confidence: 15, user_id: user.id } }]
              )
            },
            {
              prediction: HashWithIndifferentAccess.new(
                id: '0',
                description: 'Famine',
                deadline: 2.days.from_now.strftime('%Y-%m-%d %H:%M'),
                visibility: Visibility::VALUES[:visible_to_group],
                group_id: group.id,
                notify_creator: true,
                responses: [{ response: { id: '0', confidence: 85, user_id: user.id } }]
              )
            }
          ]
        )
      end

      specify do
        new_group.save!
        expect(PredictionGroup.count).to eq 1
        expect(Prediction.count).to eq 3
        expect(Response.count).to eq 3

        expect(new_group.description).to eq 'This will happen tomorrow'
        first_prediction = new_group.predictions[0]
        expect(first_prediction.description_with_group).to eq '[This will happen tomorrow] AIDS'
        expect(first_prediction.initial_confidence).to eq 1
        expect(first_prediction.deadline).to be > 47.hours.from_now
        expect(first_prediction.visibility).to eq 'visible_to_group'
        expect(first_prediction.group_id).to eq group.id
        expect(first_prediction.deadline_notifications.count).to eq 0

        second_prediction = new_group.predictions[1]
        expect(second_prediction.description_with_group).to eq '[This will happen tomorrow] War'
        expect(second_prediction.initial_confidence).to eq 15
        expect(second_prediction.deadline).to be > 47.hours.from_now
        expect(second_prediction.visibility).to eq 'visible_to_group'
        expect(second_prediction.group_id).to eq group.id
        expect(second_prediction.deadline_notifications.count).to eq 1

        third_prediction = new_group.predictions[2]
        expect(third_prediction.description_with_group).to eq '[This will happen tomorrow] Famine'
        expect(third_prediction.initial_confidence).to eq 85
        expect(third_prediction.deadline).to be > 47.hours.from_now
        expect(third_prediction.visibility).to eq 'visible_to_group'
        expect(third_prediction.group_id).to eq group.id
        expect(third_prediction.deadline_notifications.count).to eq 1
      end

      context 'updating confidences' do
        let(:prediction_group) do
          FactoryBot.create(:prediction_group, predictions: 3, creator: user,
                                                description: 'This will happen tomorrow')
        end
        let(:first_prediction) { prediction_group.predictions[0] }
        let(:second_prediction) { prediction_group.predictions[1] }
        let(:third_prediction) { prediction_group.predictions[2] }
        let(:params) do
          HashWithIndifferentAccess.new(
            id: prediction_group.id,
            description: prediction_group.description,
            predictions: [
              {
                prediction: HashWithIndifferentAccess.new(
                  id: first_prediction.id,
                  description: first_prediction.description,
                  deadline: first_prediction.deadline,
                  visibility: first_prediction.visibility,
                  group_id: first_prediction.group_id,
                  responses: [{ response: { id: first_prediction.responses.first.id, confidence: 1, user_id: user.id } }]
                )
              },
              {
                prediction: HashWithIndifferentAccess.new(
                  id: second_prediction.id,
                  description: second_prediction.description,
                  deadline: second_prediction.deadline,
                  visibility: second_prediction.visibility,
                  group_id: second_prediction.group_id,
                  responses: [{ response: { id: second_prediction.responses.first.id, confidence: 15, user_id: user.id } }]
                )
              },
              {
                prediction: HashWithIndifferentAccess.new(
                  id: third_prediction.id,
                  description: third_prediction.description,
                  deadline: third_prediction.deadline,
                  visibility: third_prediction.visibility,
                  group_id: third_prediction.group_id,
                  responses: [{ response: { id: third_prediction.responses.first.id, confidence: 85, user_id: user.id } }]
                )
              }
            ]
          )
        end

        before { prediction_group }

        specify do
          expect { new_group.save! }
            .not_to change { [PredictionGroup.first.updated_at, Prediction.maximum(:updated_at)] }
          expect(PredictionGroup.count).to eq 1
          expect(Prediction.count).to eq 3
          expect(Response.count).to eq 6

          expect(new_group.description).to eq 'This will happen tomorrow'

          first_prediction.reload
          expect(first_prediction.responses.last.confidence).to eq 1

          second_prediction.reload
          expect(second_prediction.responses.last.confidence).to eq 15

          third_prediction.reload
          expect(third_prediction.responses.last.confidence).to eq 85
        end
      end
    end
  end
end
