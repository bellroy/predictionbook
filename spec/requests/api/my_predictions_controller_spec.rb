# frozen_string_literal: true

require 'spec_helper'

describe Api::MyPredictionsController, type: :request do
  subject(:server_response) do
    get url, params: params
    response
  end

  let(:user) { FactoryGirl.create(:user, api_token: 'real-token') }
  let(:prediction) { FactoryGirl.create(:prediction, creator: user) }
  let(:another_prediction) { FactoryGirl.create(:prediction) }

  before do
    user
    prediction
    another_prediction
  end

  describe '#index' do
    let(:url) { '/api/my_predictions' }
    let(:params) { { api_token: user.api_token } }

    context do
      it { is_expected.to have_http_status(:ok) }

      specify do
        json_array = JSON.parse(server_response.body)
        expect(json_array.length).to eq 1
        expect(json_array.first['description']).to eq prediction.description
      end
    end

    context do
      let(:params) { {} }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context do
      let(:params) { { api_token: 'a-fake-api-token' } }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context do
      let(:another_prediction) do
        FactoryGirl.create(:prediction, creator: user, created_at: 1.minute.from_now)
      end

      specify do
        get url, params: params
        json_array = JSON.parse(response.body)
        expect(json_array.length).to eq 2

        get url, params: params.merge(page_size: 1, page: 1)
        json_array = JSON.parse(response.body)
        expect(json_array.length).to eq 1
        expect(json_array.first['description']).to eq another_prediction.description

        get url, params: params.merge(page_size: 1, page: 2)
        json_array = JSON.parse(response.body)
        expect(json_array.length).to eq 1
        expect(json_array.first['description']).to eq prediction.description
      end
    end
  end
end
