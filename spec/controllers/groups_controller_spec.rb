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
      before { sign_in user }

      let(:user) { FactoryGirl.create(:user) }

      specify do
        expect { index }.to raise_error ActionController::RoutingError
      end

      context 'no matching group exists' do
        before { FactoryGirl.create(:group) }

        specify do
          expect { index }.to raise_error ActionController::RoutingError
        end
      end

      context 'matching group exists' do
        before { FactoryGirl.create(:group_member, user: user) }

        specify do
          index
          expect(response).to render_template :index
          expect(assigns[:groups]).not_to be_nil
        end
      end
    end
  end

  describe 'GET show' do
    subject(:show) { get :show, id: group.id }

    let(:group) { FactoryGirl.create(:group) }

    context 'not logged in' do
      specify do
        show
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'logged in' do
      before { sign_in user }

      let(:user) { FactoryGirl.create(:user) }

      specify do
        FactoryGirl.create(:group_member, user: user, group: group)
        show
        expect(response).to render_template :show
        expect(assigns[:group]).not_to be_nil
        expect(assigns[:predictions]).not_to be_nil
      end

      context 'email does not match group' do
        specify do
          expect { show }.to raise_error ActionController::RoutingError
        end
      end
    end
  end
end
