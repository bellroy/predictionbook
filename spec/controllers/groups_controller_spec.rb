# frozen_string_literal: true

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
      before do
        sign_in user
        group
      end

      let(:group) { FactoryGirl.create(:group) }
      let(:user) { FactoryGirl.create(:user) }

      specify do
        index
        expect(response).to render_template :index
        expect(assigns[:groups]).to be_empty
      end

      context 'user is in a group' do
        before { FactoryGirl.create(:group_member, group: group, user: user) }

        specify do
          index
          expect(response).to render_template :index
          expect(assigns[:groups]).to eq [group]
        end
      end

      context 'user is an invitee to a group' do
        before { FactoryGirl.create(:group_member, :invitee, group: group, user: user) }

        specify do
          index
          expect(response).to render_template :index
          expect(assigns[:groups]).to be_empty
        end
      end
    end
  end

  describe 'GET show' do
    subject(:show) { get :show, params: { id: group.id } }

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

      context 'user not a member of group' do
        specify do
          expect { show }.to raise_error ActionController::RoutingError
        end
      end

      context 'user is an invitee but has not accepted invitation' do
        specify do
          FactoryGirl.create(:group_member, :invitee, user: user, group: group)
          expect { show }.to raise_error ActionController::RoutingError
        end
      end
    end
  end

  describe 'GET new' do
    subject(:new) { get :new }

    context 'not logged in' do
      specify do
        new
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'logged in' do
      before { sign_in user }

      let(:user) { FactoryGirl.create(:user) }

      specify do
        new
        expect(response).to render_template :new
        expect(assigns[:group]).not_to be_nil
      end
    end
  end

  describe 'POST create' do
    subject(:create) { post :create, params: params }

    let(:params) do
      { group: { name: 'my new group' }, invitees: "me\nyou\nhim" }
    end

    context 'not logged in' do
      specify do
        create
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'logged in' do
      before do
        sign_in user
        FactoryGirl.create(:user, login: 'me')
        FactoryGirl.create(:user, login: 'you')
      end

      let(:user) { FactoryGirl.create(:user, login: 'admin') }

      specify do
        expect(GroupMemberMailer).to receive(:invitation).exactly(2).times.and_call_original
        create
        expect(response).to redirect_to group_path(Group.last)
        expect(assigns[:group].name).to eq 'my new group'
        expect(assigns[:group].group_members.count).to eq 3
      end

      context 'duplicate name' do
        before { FactoryGirl.create(:group, name: 'my new group') }

        specify do
          expect(GroupMemberMailer).not_to receive(:invitation)
          create
          expect(response).to render_template :new
          expect(assigns[:group].name).to eq 'my new group'
          expect(flash[:error]).to eq 'Name has already been taken'
        end
      end
    end
  end

  describe 'GET edit' do
    subject(:edit) { get :edit, params: { id: group.id } }

    let(:group) { FactoryGirl.create(:group) }

    context 'not logged in' do
      specify do
        edit
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'logged in' do
      before { sign_in user }

      let(:user) { FactoryGirl.create(:user) }

      context 'current user is not group admin' do
        before do
          FactoryGirl.create(:group_member, :contributor, group: group, user: user)
        end

        specify do
          edit
          expect(response).to redirect_to root_url
          expect(flash[:notice]).to eq 'You are not authorized to perform that action'
        end
      end

      context 'current user is group admin' do
        before do
          FactoryGirl.create(:group_member, :admin, group: group, user: user)
        end

        specify do
          edit
          expect(response).to render_template :edit
          expect(assigns[:group]).to eq group
        end
      end
    end

    describe 'PUT update' do
      subject(:update) { put :update, params: params }

      let(:params) do
        { id: group.id, group: { name: 'my new group' }, invitees: 'me@email.com' }
      end

      context 'not logged in' do
        specify do
          update
          expect(response).to redirect_to new_user_session_path
        end
      end

      context 'logged in' do
        before do
          sign_in user
          FactoryGirl.create(:user, email: 'me@email.com')
          FactoryGirl.create(:user, email: 'you@email.com')
        end

        let(:user) { FactoryGirl.create(:user, email: 'admin@email.com') }

        context 'current user is not group admin' do
          before do
            FactoryGirl.create(:group_member, :contributor, group: group, user: user)
          end

          specify do
            update
            expect(response).to redirect_to root_url
            expect(flash[:notice]).to eq 'You are not authorized to perform that action'
          end
        end

        context 'current user is group admin' do
          before do
            FactoryGirl.create(:group_member, :admin, group: group, user: user)
          end

          specify do
            update
            expect(response).to redirect_to group_path(group)
            expect(assigns[:group].name).to eq 'my new group'
            expect(assigns[:group].group_members.count).to eq 1
          end

          context 'duplicate name' do
            before { FactoryGirl.create(:group, name: 'my new group') }

            specify do
              update
              expect(response).to render_template :edit
              expect(assigns[:group].name).to eq 'my new group'
              expect(flash[:error]).to eq 'Name has already been taken'
            end
          end
        end
      end
    end

    describe 'DELETE destroy' do
      subject(:destroy) { delete :destroy, params: { id: group.id } }

      let(:group) { FactoryGirl.create(:group) }

      context 'not logged in' do
        specify do
          destroy
          expect(response).to redirect_to new_user_session_path
        end
      end

      context 'logged in' do
        before { sign_in user }

        let(:user) { FactoryGirl.create(:user) }

        context 'current user is not group admin' do
          before do
            FactoryGirl.create(:group_member, :contributor, group: group, user: user)
          end

          specify do
            destroy
            expect(response).to redirect_to root_url
            expect(flash[:notice]).to eq 'You are not authorized to perform that action'
          end
        end

        context 'current user is group admin' do
          before do
            FactoryGirl.create(:group_member, :admin, group: group, user: user)
          end

          specify do
            destroy
            expect(response).to redirect_to groups_path
            expect(Group.count).to be_zero
          end
        end
      end
    end
  end
end
