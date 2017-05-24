# encoding: utf-8

require 'spec_helper'

describe Api::CurrentUsersController, type: :controller do
  let!(:user) { FactoryGirl.create(:user, api_token: 'real-token') }

  describe 'GET show' do
    context 'with valid API token' do
      before do
        get :show, id: 'me', api_token: user.api_token
      end

      specify do
        expect(response).to be_success
        expect(response.content_type).to eq(Mime::JSON)
        expect(response.body).to include user.login
      end
    end

    context 'with invalid API token' do
      before { get :show, id: 'me', api_token: 'fake-token' }

      specify do
        expect(response).to_not be_success
        expect(response.content_type).to eq(Mime::JSON)
      end
    end
  end
end
