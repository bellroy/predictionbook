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

      specify do
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

      specify do
        get url, params: params
        json_hash = JSON.parse(response.body)
        predictions = json_hash['predictions']
        expect(predictions.length).to eq 2

        before_judgment_timestamp = Time.now
        another_prediction.judgements.create!(outcome: true)

        get url, params: params.merge(page_size: 1, page: 1)
        json_hash = JSON.parse(response.body)
        predictions = json_hash['predictions']
        actor = json_hash['user']
        expect(predictions.length).to eq 1
        expect(predictions.first['description']).to eq another_prediction.description
        expect(Time.parse(predictions.first['last_judgement_at']) >= before_judgment_timestamp).to be true
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

    context 'when specifying tags' do
      let(:params) { { api_token: user.api_token, tag_names: ['mars'] } }
      let(:tagged_prediction) do
        FactoryBot.create(
          :prediction,
          creator: user,
          tag_names: ['mars', 'rockets']
        )
      end

      before { user && prediction && tagged_prediction }

      it 'returns only those predictions with matching tags' do
        json_hash = JSON.parse(server_response.body)
        descriptions = json_hash['predictions'].map do |prediction|
          prediction['description']
        end
        expect(descriptions).to include(tagged_prediction.description)
        expect(descriptions).not_to include(prediction.description)
      end
    end
  end
end
