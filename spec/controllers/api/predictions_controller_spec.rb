# encoding: utf-8
require 'spec_helper'

describe Api::PredictionsController, type: :controller do
  let(:user) { valid_user }
  let(:user_with_token) do
    user.api_token = 'token'
    user
  end
  let(:prediction) { build(:prediction) }
  let(:predicitons) { [prediction] }
  let(:token) { 'real-token' }

  describe 'GET /predictions' do
    context 'with valid API token' do
      let(:recent) { double(:recent_predictions) }

      before do
        allow(User).to receive(:find_by_api_token).and_return(user_with_token)

        allow(Prediction).to receive(:limit).with(100)
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

  describe 'GET /predictions/:id' do
    context 'with valid API token' do
      before do
        allow(User).to receive(:find_by_api_token).and_return(user_with_token)

        allow(Prediction).to receive(:find).with(prediction.id)
          .and_return(prediction)

        get :show, id: prediction.id, api_token: user_with_token.api_token
      end

      specify { expect(response).to be_success }
      specify { expect(response.content_type).to eq(Mime::JSON) }
      specify { expect(response.body).to_not be_empty }
    end

    context 'with invalid API token' do
      before { get :show, id: prediction.id, api_token: 'fake-token' }

      specify { expect(response).to_not be_success }
      specify { expect(response.content_type).to eq(Mime::JSON) }
    end

    context 'with non-existent id' do
      before { get :show, id: 999, api_token: 'fake-token' }

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
      let(:user_with_email) { build(:user_with_email, api_token: token) }

      before do
        allow(User).to receive(:find_by_api_token)
          .with(token).and_return(user_with_email)
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

  describe 'PUT /predictions/:id' do
    let(:new_prediction_params) do
      { description: 'The world definitely will not end tomorrow!' }
    end
    let(:user) { valid_user(api_token: token) }
    let(:prediction) { valid_prediction(creator: user) }
    before { prediction.save }

    context 'with valid API token' do
      context 'authorized user' do
        before do
          put :update,
              api_token: user.api_token,
              id: prediction.id,
              prediction: new_prediction_params
        end

        specify { expect(response).to be_success }
        specify { expect(response.content_type).to eq(Mime::JSON) }

        it 'updates the existing prediction' do
          description = new_prediction_params[:description]
          prediction.reload

          expect(prediction.description).to eq(description)
        end
      end

      context 'unauthorized user' do
        before do
          put :update,
              api_token: 'fake-token',
              id: prediction.id,
              prediction: new_prediction_params
        end

        specify { expect(response).to_not be_success }
        specify { expect(response.content_type).to eq(Mime::JSON) }
      end
    end

    context 'with invalid API token' do
      before do
        put :update,
            api_token: 'fake-token',
            id: prediction.id,
            prediction: new_prediction_params
      end

      specify { expect(response).to_not be_success }
      specify { expect(response.content_type).to eq(Mime::JSON) }
    end
  end
end
