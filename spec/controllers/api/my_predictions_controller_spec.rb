# frozen_string_literal: true

require 'spec_helper'

describe Api::MyPredictionsController, type: :controller do
  let(:user) { FactoryBot.create(:user, api_token: 'real-token', name: 'Freddy') }

  before do
    user
  end

  describe 'GET /api/my_predictions' do
    context 'with valid API token' do
      context 'and a public prediction' do
        let(:my_prediction) { FactoryBot.create(:prediction, creator: user) }
        let(:her_prediction) { FactoryBot.create(:prediction) }
        let(:parsed_response) { JSON.parse(response.body) }

        before do
          my_prediction
          her_prediction
          get :index, params: { api_token: user.api_token }
        end

        specify 'works', :aggregate_failures do
          expect(response).to be_ok
          expect(response.content_type).to eq 'application/json'
        end

        it 'includes my prediction' do
          expect(parsed_response['predictions'].to_s)
            .to include my_prediction.description_with_group
          expect(parsed_response['user']['name']).to eq user.name
          expect(parsed_response['user']['user_id']).to eq user.id
          expect(parsed_response['user']['email']).to eq user.email
          expect(parsed_response['predictions'].to_s).not_to include user.email
          expect(parsed_response['predictions'].to_s).to include 'outcome'
          expect(parsed_response['predictions'].to_s).to include 'description_with_group'
          expect(parsed_response['predictions'].to_s).to include 'responses'
        end

        it "does not includes someone else's prediction" do
          expect(response.body).not_to include her_prediction.description_with_group
        end
      end
    end

    context 'with invalid API token' do
      before { get :index, params: { api_token: 'fake-token' } }

      specify 'works', :aggregate_failures do
        expect(response).not_to be_ok
        expect(response.content_type).to eq 'application/json'
      end
    end
  end
end
