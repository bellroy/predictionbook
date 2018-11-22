# frozen_string_literal: true

require 'spec_helper'

module Api
  describe PredictionGroupByDescriptionController, type: :controller do
    let!(:user) { FactoryBot.create(:user, api_token: 'real-token') }
    let!(:prediction_group) { FactoryBot.create(:prediction_group, predictions: 1) }

    describe 'update' do
      let(:new_prediction_group_params) do
        {
          description: 'The world will end tomorrow!',
          deadline_text: 'in 1 day',
          prediction_0_description: 'AIDS',
          prediction_0_initial_confidence: 1,
          prediction_1_description: 'War',
          prediction_1_initial_confidence: 15,
          prediction_2_description: 'Famine',
          prediction_2_initial_confidence: 85
        }
      end
      let(:prediction_group) do
        FactoryBot.create(:prediction_group, creator: user, predictions: 1)
      end

      context 'with valid API token' do
        context 'authorized user' do
          subject(:update) { put :update, params: params }

          let(:params) do
            {
              api_token: user.api_token,
              id: id,
              prediction_group: new_prediction_group_params
            }
          end
          let(:id) { prediction_group.description }

          specify do
            update
            expect(response).to be_ok
            expect(response.content_type).to eq 'application/json'

            description = new_prediction_group_params[:description]
            prediction_group.reload
            expect(prediction_group.description).to eq(description)
          end

          context 'prediction group does not exist' do
            let(:id) { 'some description that does not exist' }

            specify do
              expect { update }.to change(PredictionGroup, :count).by(1)
            end
          end
        end

        context 'unauthorized user' do
          before do
            put :update, params: { api_token: 'fake-token',
                                   id: prediction_group.description,
                                   prediction_group: new_prediction_group_params }
          end

          specify do
            expect(response).not_to be_ok
            expect(response.content_type).to eq 'application/json'
          end
        end
      end

      context 'with invalid API token' do
        before do
          put :update, params: { api_token: 'fake-token',
                                 id: prediction_group.description,
                                 prediction_group: new_prediction_group_params }
        end

        specify do
          expect(response).not_to be_ok
          expect(response.content_type).to eq 'application/json'
        end
      end
    end
  end
end
