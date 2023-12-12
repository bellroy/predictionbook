# frozen_string_literal: true

require 'spec_helper'

describe UsersController do
  let(:logged_in_user) { FactoryBot.create(:user, api_token: 'other-real-token') }
  let(:target_user) { FactoryBot.create(:user, api_token: 'real-token') }

  before do
    sign_in logged_in_user if logged_in_user.present?
    expect(controller).to receive(:set_timezone)
  end

  describe '#show' do
    subject(:show) { get :show, params: { id: target_user.id } }

    context 'logged in user and target user are the same' do
      let(:target_user) { logged_in_user }

      specify do
        show
        expect(assigns[:predictions].map(&:id)).to eq logged_in_user.predictions.map(&:id)
        expect(assigns[:user]).to eq target_user
      end

      context 'when requesting a particular page number' do
        it 'renders the proper template without blowing up' do
          get :show, params: { id: target_user.id, page: '2' }
          expect(response).to render_template :show
        end
      end
    end

    context 'logged in user and target user are different' do
      specify do
        FactoryBot.create(:prediction, creator: target_user)

        show
        expect(assigns[:predictions].map(&:id)).to eq target_user.predictions.map(&:id)
        expect(assigns[:user]).to eq target_user
      end
    end
  end

  describe '#statistics' do
    subject(:statistics) { get :statistics, params: { id: user_id } }

    let(:user_id) { target_user.id }

    it 'delegates to the statistics to the user' do
      expect_any_instance_of(User).to receive(:statistics).and_return(:stats)
      statistics
      expect(assigns[:statistics]).to eq :stats
    end
  end

  describe 'users setting page' do
    subject(:settings) { get :settings, params: { id: user_id } }

    let(:user_id) { target_user.id }

    context 'not logged in' do
      let(:logged_in_user) { nil }

      specify do
        settings
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    it '403s on user if they are not the described user' do
      settings
      expect(response.response_code).to eq 403
    end

    context 'target user is logged in user' do
      let(:target_user) { logged_in_user }

      specify do
        settings
        expect(response).to be_ok
        expect(assigns[:user]).to eq target_user
      end
    end

    context 'cannot show settings using api token' do
      let(:user_id) { logged_in_user.api_token }

      specify do
        expect { settings }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
