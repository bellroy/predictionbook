require 'spec_helper'

describe UsersController do
  let(:logged_in_user) { FactoryGirl.create(:user) }
  let(:target_user) { FactoryGirl.create(:user) }

  before(:each) do
    sign_in logged_in_user if logged_in_user.present?
    expect(controller).to receive(:set_timezone)
  end

  describe '#show' do
    let(:relation) { class_double(Prediction) }

    before do
      expect_any_instance_of(User).to receive(:predictions).and_return relation
    end

    subject(:show) { get :show, id: target_user.id }

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
        expect(relation).to receive(:not_private).and_return predictions
        paged_predictions = class_double(Prediction)
        expect(predictions).to receive(:page).and_return(paged_predictions)

        show
        expect(assigns[:predictions]).to eq paged_predictions
        expect(assigns[:user]).to eq target_user
      end
    end
  end

  describe '#statistics' do
    subject(:statistics) { get :statistics, id: target_user.id }

    it 'delegates to the statistics to the user' do
      expect_any_instance_of(User).to receive(:statistics).and_return(:stats)
      statistics
      expect(assigns[:statistics]).to eq :stats
    end
  end

  describe 'users setting page' do
    subject(:settings) { get :settings, id: target_user.id }

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
        expect(response).to be_success
        expect(assigns[:user]).to eq target_user
      end
    end
  end
end
