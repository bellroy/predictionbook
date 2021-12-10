# frozen_string_literal: true

require 'spec_helper'

describe Api::MyPredictionsController, type: :request do
  subject(:server_response) do
    get url, params: params
    response
  end

  let(:user) { FactoryBot.create(:user, api_token: 'real-token') }
  let(:prediction) { FactoryBot.create(:prediction, creator: user) }
  let(:another_prediction) { FactoryBot.create(:prediction) }

  describe '#index' do
    let(:url) { '/api/my_predictions' }
    let(:params) { { api_token: user.api_token } }

    context do
      before { user && prediction && another_prediction }

      it { is_expected.to have_http_status(:ok) }

      it do
        json_hash = JSON.parse(server_response.body)
        predictions = json_hash['predictions']
        actor = json_hash['user']
        expect(predictions.length).to eq 1
        expect(predictions.first['description']).to eq prediction.description
        expect(actor['email']).to eq user.email
      end
    end

    context do
      let(:params) { {} }

      before { user && prediction && another_prediction }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context do
      let(:params) { { api_token: 'a-fake-api-token' } }

      before { user && prediction && another_prediction }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context do
      let(:another_prediction) do
        FactoryBot.create(:prediction, creator: user, created_at: 1.minute.from_now)
      end

      before { user && prediction && another_prediction }

      it do
        get url, params: params
        json_hash = JSON.parse(response.body)
        predictions = json_hash['predictions']
        expect(predictions.length).to eq 2

        get url, params: params.merge(page_size: 1, page: 1)
        json_hash = JSON.parse(response.body)
        predictions = json_hash['predictions']
        actor = json_hash['user']
        expect(predictions.length).to eq 1
        expect(predictions.first['description']).to eq another_prediction.description
        expect(actor['email']).to eq user.email

        get url, params: params.merge(page_size: 1, page: 2)
        json_hash = JSON.parse(response.body)
        predictions = json_hash['predictions']
        actor = json_hash['user']
        expect(predictions.length).to eq 1
        expect(predictions.first['description']).to eq prediction.description
        expect(actor['email']).to eq user.email
      end
    end
  end
end
