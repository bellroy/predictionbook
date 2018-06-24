# frozen_string_literal: true

require 'spec_helper'

describe Api::MyPredictionsController, type: :controller do
  let(:user) { FactoryGirl.create(:user, api_token: 'real-token', name: 'Freddy') }

  before do
    user
  end

  describe 'GET /api/my_predictions' do
    context 'with valid API token' do
      context 'and a public prediction' do
        let(:my_prediction) { FactoryGirl.create(:prediction, creator: user) }
        let(:her_prediction) { FactoryGirl.create(:prediction) }
        before do
          my_prediction
          her_prediction
          get :index, params: { api_token: user.api_token }
        end

        specify { expect(response).to be_success }
        specify { expect(response.content_type).to eq 'application/json' }
        it 'includes my prediction' do
          expect(response.body).to include my_prediction.description_with_group
          expect(response.body).to include user.name
          expect(response.body).to include user.login
          expect(response.body).to include user.email
        end
        it "does not includes someone else's prediction" do
          expect(response.body).to_not include her_prediction.description_with_group
        end
      end
    end

    context 'with invalid API token' do
      before { get :index, params: { api_token: 'fake-token' } }

      specify { expect(response).to_not be_success }
      specify { expect(response.content_type).to eq 'application/json' }
    end
  end
end
