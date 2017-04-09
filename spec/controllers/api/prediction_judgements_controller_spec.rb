# encoding: utf-8

require 'spec_helper'

describe Api::PredictionJudgementsController, type: :controller do
  let(:user) { FactoryGirl.create(:user, api_token: 'real-token') }

  before { user }

  describe 'POST create' do
    subject(:create) { post :create, params }

    let(:api_token) { 'real-token' }
    let(:params) { { prediction_id: 123, outcome: 'right', api_token: api_token } }

    context 'with valid API token' do
      before do
        judgement = instance_double(Judgement, to_json: 'my new judgement')
        prediction = instance_double(Prediction, judgements: [judgement])
        expect(Prediction).to receive(:find).with('123').and_return(prediction)
        expect(prediction).to receive(:judge!).with('right', user)

        expect(User).to receive(:find_by).with(api_token: 'real-token').and_return(user)
        expect(user).to receive(:authorized_for).with(prediction).and_return(true)
      end

      it 'judges the prediction' do
        create
        expect(response).to be_success
        expect(response.body).to eq 'my new judgement'
      end
    end

    context 'with invalid API token' do
      let(:api_token) { 'fake-token' }

      specify do
        create
        expect(response).not_to be_success
      end
    end
  end
end
