# frozen_string_literal: true

require 'spec_helper'

module Api
  describe PredictionGroupsController, type: :controller do
    let!(:user) { FactoryGirl.create(:user, api_token: 'real-token') }
    let!(:prediction_group) { FactoryGirl.create(:prediction_group, predictions: 1) }

    describe 'index' do
      context 'with valid API token' do
        before do
          Prediction.update_all(visibility: Visibility::VALUES[:visible_to_everyone])
          get :index, params: { api_token: user.api_token }
        end

        specify { expect(response).to be_success }
        specify { expect(response.content_type).to eq 'application/json' }
        specify { expect(response.body).to include prediction_group.description }
      end

      context 'with invalid API token' do
        before { get :index, params: { api_token: 'fake-token' } }

        specify { expect(response).to_not be_success }
        specify { expect(response.content_type).to eq 'application/json' }
      end
    end

    describe 'show' do
      context 'with valid API token' do
        before do
          get :show, params: { id: prediction_group.id, api_token: user.api_token }
        end

        specify { expect(response).to be_success }
        specify { expect(response.content_type).to eq 'application/json' }
        specify { expect(response.body).to_not be_empty }
      end

      context 'with invalid API token' do
        before { get :show, params: { id: prediction_group.id, api_token: 'fake-token' } }

        specify { expect(response).to_not be_success }
        specify { expect(response.content_type).to eq 'application/json' }
      end

      context 'with non-existent id' do
        before { get :show, params: { id: 999, api_token: 'fake-token' } }

        specify { expect(response).to_not be_success }
        specify { expect(response.content_type).to eq 'application/json' }
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

          specify { expect(response).to_not be_success }
          specify { expect(response.body).to include('a probability is between') }
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
        end

        specify { expect(response).to_not be_success }
      end
    end

    describe 'update' do
      let(:new_prediction_group_params) do
        { description: 'The world definitely will not end tomorrow!' }
      end
      let(:prediction_group) do
        FactoryGirl.create(:prediction_group, creator: user, predictions: 1)
      end

      context 'with valid API token' do
        context 'authorized user' do
          before do
            put :update, params: { api_token: user.api_token,
                                   id: prediction_group.id,
                                   prediction_group: new_prediction_group_params }
          end

          specify { expect(response).to be_success }
          specify { expect(response.content_type).to eq 'application/json' }

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

          specify { expect(response).to_not be_success }
          specify { expect(response.content_type).to eq 'application/json' }
        end
      end

      context 'with invalid API token' do
        before do
          put :update, params: { api_token: 'fake-token',
                                 id: prediction_group.id,
                                 prediction_group: new_prediction_group_params }
        end

        specify { expect(response).to_not be_success }
        specify { expect(response.content_type).to eq 'application/json' }
      end
    end
  end
end
