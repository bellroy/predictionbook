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

    let(:relation) { class_double(Prediction) }

    before do
      expect_any_instance_of(User).to receive(:predictions).and_return relation
    end

    context 'logged in user and target user are the same' do
      let(:target_user) { logged_in_user }

      specify do
        predictions = instance_double(ActiveRecord::Relation)
        expect(relation).to receive(:page).and_return(predictions)
        show
        expect(assigns[:predictions]).to eq predictions
        expect(assigns[:user]).to eq target_user
      end
    end

    context 'logged in user and target user are different' do
      specify do
        predictions = class_double(Prediction)
        expect(relation).to receive(:visible_to_everyone).and_return predictions
        paged_predictions = class_double(Prediction)
        expect(predictions).to receive(:page).and_return(paged_predictions)

        show
        expect(assigns[:predictions]).to eq paged_predictions
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

  describe '#destroy' do
    subject(:destroy)   { delete :destroy, params: { id: user_id } }
    let(:user_id) { logged_in_user.id }

    it "pseudonymizes the user's associated records and deletes the account" do
      FactoryBot.create(:user, :pseudonymous)
      allow(logged_in_user).to receive(:pseudonymize!).and_return(true)
      destroy
      expect(response).to redirect_to root_path
      expect(User.find_by(id: user_id)).to_not be
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

  describe 'PUT update' do
    subject(:update) { put :update, params: { id: user_id, user: user_params } }

    let(:group) { FactoryBot.create(:group) }
    let(:user_params) { { visibility_default: "visible_to_group_#{group.id}" } }

    context 'not logged in user' do
      let(:user_id) { FactoryBot.create(:user).id }

      specify do
        update
        expect(response).to be_forbidden
      end
    end

    context 'logged in user' do
      let(:user_id) { logged_in_user.id }

      specify do
        update
        expect(response).to render_template :show
        logged_in_user.reload
        expect(logged_in_user.visibility_default).to eq 'visible_to_group'
        expect(logged_in_user.group_default_id).to eq group.id
      end
    end
  end
end
