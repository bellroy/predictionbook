require 'spec_helper'

describe GroupsController do
  describe 'GET index' do
    subject(:index) { get :index }

    context 'not logged in' do
      specify do
        index
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'logged in' do
      before { sign_in FactoryGirl.create(:user, email: 'bob@trikeapps.com') }

      specify do
        expect { index }.to raise_error ActionController::RoutingError
      end

      context 'no matching group exists' do
        before { FactoryGirl.create(:group, email_domains: 'trickapps.com') }

        specify do
          expect { index }.to raise_error ActionController::RoutingError
        end
      end

      context 'matching group exists' do
        before { FactoryGirl.create(:group, email_domains: 'trikeapps.com') }

        specify do
          index
          expect(response).to render_template :index
        end
      end
    end
  end

  describe 'GET show' do
    subject(:show) { get :show, id: group.id }

    let(:group) { FactoryGirl.create(:group, email_domains: 'trikeapps.com') }

    context 'not logged in' do
      specify do
        show
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'logged in' do
      before { sign_in FactoryGirl.create(:user, email: email) }

      let(:email) { 'bob@trikeapps.com' }

      specify do
        show
        expect(response).to render_template :show
      end

      context 'email does not match group' do
        let(:email) { 'bob@trickapps.com' }

        specify do
          expect { show }.to raise_error ActionController::RoutingError
        end
      end
    end
  end
end
