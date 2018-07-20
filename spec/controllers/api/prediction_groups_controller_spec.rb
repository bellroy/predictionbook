# frozen_string_literal: true

require 'spec_helper'

module Api
  describe PredictionGroupsController, type: :controller do
    let!(:user) { FactoryBot.create(:user, api_token: 'real-token') }
    let!(:prediction_group) { FactoryBot.create(:prediction_group, predictions: 1) }

    describe 'index' do
      context 'with valid API token' do
        before do
          Prediction.update_all(visibility: Visibility::VALUES[:visible_to_everyone])
          get :index, params: { api_token: user.api_token }
        end

        specify do
          expect(response).to be_success
          expect(response.content_type).to eq 'application/json'
          expect(response.body).to include prediction_group.description
        end
      end

      context 'with invalid API token' do
        before { get :index, params: { api_token: 'fake-token' } }

        specify do
          expect(response).to_not be_success
          expect(response.content_type).to eq 'application/json'
        end
      end
    end

    describe 'show' do
      subject(:show) { get :show, params: params }

      context 'with valid API token' do
        let(:params) { { id: prediction_group.id, api_token: user.api_token } }

        specify do
          show
          expect(response).to be_success
          expect(response.content_type).to eq 'application/json'
          expect(response.body).to_not be_empty
        end
      end

      context 'with invalid API token' do
        let(:params) { { id: prediction_group.id, api_token: 'fake-token' } }

        specify do
          show
          expect(response).to_not be_success
          expect(response.content_type).to eq 'application/json'
        end
      end

      context 'with non-existent id' do
        let(:params) { { id: 999, api_token: user.api_token } }

        specify { expect { show }.to raise_error ActiveRecord::RecordNotFound }
      end
    end

    describe 'create' do
      let(:prediction_group_params) do
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

      context 'with valid API token' do
        it 'creates a new prediction_group' do
          post :create, params: { prediction_group: prediction_group_params,
                                  api_token: user.api_token }
          expect(response.body).to include(prediction_group_params[:description])
          expect(response.body).to include('AIDS')
          expect(response.body).to include('War')
          expect(response.body).to include('Famine')
        end

        context 'with a malformed prediction_group' do
          before do
            prediction_group_params[:prediction_0_initial_confidence] = 9000
            post :create, params: { prediction_group: prediction_group_params,
                                    api_token: user.api_token }
          end

          specify do
            expect(response).to_not be_success
            expect(response.body).to include('a probability is between')
          end
        end

        context 'with new visibility' do
          let(:prediction_group_params) do
            {
              description: 'The world will end tomorrow!',
              deadline_text: 'in 1 day',
              prediction_0_description: 'AIDS',
              prediction_0_initial_confidence: 1,
              prediction_1_description: 'War',
              prediction_1_initial_confidence: 15,
              prediction_2_description: 'Famine',
              prediction_2_initial_confidence: 85,
              visibility: 'visible_to_creator'
            }
          end

          before do
            post :create, params: { prediction_group: prediction_group_params,
                                    api_token: user.api_token }
          end

          specify do
            expect(Prediction.count).to eq 4
            expect(Prediction.last.visible_to_creator?).to be true
          end
        end
      end

      context 'with invalid API token' do
        before do
          post :create, params: { api_token: 'fake-token',
                                  prediction_group: prediction_group_params }
        end

        specify do
          expect(response.body).to_not include(prediction_group_params[:description])
          expect(response).to_not be_success
        end

      end
    end

    describe 'update' do
      let(:new_prediction_group_params) do
        { description: 'The world definitely will not end tomorrow!' }
      end
      let(:prediction_group) do
        FactoryBot.create(:prediction_group, creator: user, predictions: 1)
      end

      context 'with valid API token' do
        context 'authorized user' do
          before do
            put :update, params: { api_token: user.api_token,
                                   id: prediction_group.id,
                                   prediction_group: new_prediction_group_params }
          end

          specify do
            expect(response).to be_success
            expect(response.content_type).to eq 'application/json'
          end

          it 'updates the existing prediction_group' do
            description = new_prediction_group_params[:description]
            prediction_group.reload

            expect(prediction_group.description).to eq(description)
          end
        end

        context 'unauthorized user' do
          before do
            put :update, params: { api_token: 'fake-token',
                                   id: prediction_group.id,
                                   prediction_group: new_prediction_group_params }
          end

          specify do
            expect(response).to_not be_success
            expect(response.content_type).to eq 'application/json'
          end
        end
      end

      context 'with invalid API token' do
        before do
          put :update, params: { api_token: 'fake-token',
                                 id: prediction_group.id,
                                 prediction_group: new_prediction_group_params }
        end

        specify do
          expect(response).to_not be_success
          expect(response.content_type).to eq 'application/json'
        end
      end
    end
  end
end
