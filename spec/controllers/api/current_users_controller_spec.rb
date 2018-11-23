# frozen_string_literal: true

require 'spec_helper'

describe Api::CurrentUsersController, type: :controller do
  let!(:user) { FactoryBot.create(:user, api_token: 'real-token') }

  describe 'GET show' do
    context 'with valid API token' do
      before do
        get :show, params: { id: 'me', api_token: user.api_token }
      end

      specify do
        expect(response).to be_ok
        expect(response.content_type).to eq 'application/json'
        expect(response.body).to include user.login
      end
    end

    context 'with invalid API token' do
      before { get :show, params: { id: 'me', api_token: 'fake-token' } }

      specify do
        expect(response).not_to be_ok
        expect(response.content_type).to eq 'application/json'
      end
    end
  end
end
