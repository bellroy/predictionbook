# encoding: utf-8
require 'spec_helper'

describe Api::PredictionsController, type: :controller do
  let(:user) { valid_user }
  let(:prediction) { build(:prediction) }
  let(:predicitons) { [prediction] }

  before do
    controller.stub(:set_timezone)
  end

  describe 'GET /predictions' do
    context 'with valid API token' do
      let(:user_with_token) do
        user.api_token = 'token'
        user
      end
      let(:recent) { double(:recent_predictions) }

      before do
        User.stub(:find_by_api_token).and_return(user_with_token)

        Prediction.should_receive(:limit)
          .with(100)
          .and_return(double(:collection, recent: recent))

        get :index, api_token: user_with_token.api_token
      end

      specify { expect(response).to be_success }
      specify { expect(response.content_type).to eq(Mime::JSON) }
      specify { expect(response.body).to eq(recent.to_json) }
    end

    context 'with invalid API token' do
      before { get :index, api_token: 'fake-token' }

      specify { expect(response).to_not be_success }
      specify { expect(response.content_type).to eq(Mime::JSON) }
    end
  end

  describe 'POST /predictions' do
    let(:prediction_params) do
      {
        description: 'The world will end tomorrow!',
        deadline: 1.day.ago,
        initial_confidence: '100'
      }
    end

    context 'with valid API token' do
      let(:token) { 'real-token' }
      let(:user_with_email) { build(:user_with_email, api_token: token) }

      before do
        User.stub(:find_by_api_token).with(token).and_return(user_with_email)
      end

      it 'should create a new prediction' do
        post :create, prediction: prediction_params, api_token: token

        expect(response.body).to include(prediction_params[:description])
      end

      context 'with a malformed prediction' do
        before do
          prediction_params[:initial_confidence] = 9000
          post :create, prediction: prediction_params, api_token: token
        end

        specify { expect(response).to_not be_success }
        specify { expect(response.body).to include('a probability is between') }
      end
    end

    context 'with invalid API token' do
      before do
        post :create, api_token: 'fake-token', prediction: prediction_params
      end

      specify do
        expect(response.body).to_not include(prediction_params[:description])
      end
      specify { expect(response).to_not be_success }
    end
  end
end
