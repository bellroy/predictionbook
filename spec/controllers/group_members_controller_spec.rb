# frozen_string_literal: true

require 'spec_helper'

describe GroupMembersController do
  let(:group) { FactoryGirl.create(:group) }

  describe 'GET index' do
    subject(:index) { get :index, params: { group_id: group.id } }

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

      let(:user) { FactoryGirl.create(:user) }

      context 'user not in group' do
        specify do
          index
          expect(response).to redirect_to root_url
        end
      end

      context 'user is an invitee' do
        before { FactoryGirl.create(:group_member, :invitee, group: group, user: user) }

        specify do
          index
          expect(response).to redirect_to root_url
        end
      end

      context 'user is a contributor' do
        before { FactoryGirl.create(:group_member, group: group, user: user) }

        specify do
          index
          expect(response).to render_template :index
          expect(assigns[:group_members]).not_to be_empty
        end
      end

      context 'user is an admin' do
        before { FactoryGirl.create(:group_member, :admin, group: group, user: user) }

        specify do
          index
          expect(response).to render_template :index
          expect(assigns[:group_members]).not_to be_empty
        end
      end
    end
  end

  describe 'GET new' do
    subject(:new) { get :new, params: { group_id: group.id } }

    context 'not logged in' do
      specify do
        new
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'logged in' do
      before { sign_in user }

      let(:user) { FactoryGirl.create(:user) }

      context 'not member of group' do
        specify do
          new
          expect(response).to redirect_to root_url
        end
      end

      context 'user is invitee' do
        before { FactoryGirl.create(:group_member, :invitee, group: group, user: user) }

        specify do
          new
          expect(response).to redirect_to root_url
        end
      end

      context 'user is contributor' do
        before { FactoryGirl.create(:group_member, :contributor, group: group, user: user) }

        specify do
          new
          expect(response).to redirect_to group_path(group)
        end
      end

      context 'user is admin' do
        before { FactoryGirl.create(:group_member, :admin, group: group, user: user) }

        specify do
          new
          expect(response).to render_template :new
          expect(assigns[:group]).not_to be_nil
        end
      end
    end
  end

  describe 'POST create' do
    subject(:create) { post :create, params: params }

    let(:params) do
      { group_id: group.id, login: other_user.login }
    end
    let(:other_user) { FactoryGirl.create(:user) }

    context 'not logged in' do
      specify do
        create
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

      context 'not member of group' do
        specify do
          create
          expect(response).to redirect_to root_url
        end
      end

      context 'user is invitee' do
        before { FactoryGirl.create(:group_member, :invitee, group: group, user: user) }

        specify do
          create
          expect(response).to redirect_to root_url
        end
      end

      context 'user is contributor' do
        before { FactoryGirl.create(:group_member, :contributor, group: group, user: user) }

        specify do
          create
          expect(response).to redirect_to group_path(group)
        end
      end

      context 'user is admin' do
        before { FactoryGirl.create(:group_member, :admin, group: group, user: user) }

        specify do
          expect(GroupMemberMailer).to receive(:invitation).and_call_original
          create
          expect(response).to redirect_to group_group_members_path(group)
          expect(assigns[:group_member]).not_to be_nil
        end

        context 'target user already member of group' do
          let(:group_member) { FactoryGirl.create(:group_member, :invitee, group: group) }
          let(:other_user) { group_member.user }

          specify do
            create
            expect(response).to render_template :new
            expect(flash[:error]).to eq 'User has already been taken'
          end
        end
      end
    end
  end

  describe 'PUT update' do
    subject(:update) { put :update, params: params }

    let(:group_member) { FactoryGirl.create(:group_member, :invitee, group: group) }
    let(:params) do
      { group_id: group.id, id: group_member.id, role: role }
    end
    let(:role) { nil }

    context 'not logged in' do
      specify do
        update
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'logged in' do
      before do
        sign_in user
      end

      let(:user) { FactoryGirl.create(:user, email: 'admin@email.com') }

      context 'not member of group' do
        specify do
          update
          expect(response).to redirect_to root_url
        end
      end

      context 'user is invitee' do
        before { FactoryGirl.create(:group_member, :invitee, group: group, user: user) }

        specify do
          update
          expect(response).to redirect_to root_url
        end
      end

      context 'user is contributor' do
        before { FactoryGirl.create(:group_member, :contributor, group: group, user: user) }

        specify do
          update
          expect(response).to redirect_to group_path(group)
        end
      end

      context 'user is admin' do
        before { FactoryGirl.create(:group_member, :admin, group: group, user: user) }

        context 'role is nil' do
          specify do
            expect(GroupMemberMailer).to receive(:invitation).and_call_original
            update
            expect(response).to redirect_to group_group_members_path(group)
            expect(assigns[:group_member]).not_to be_nil
          end
        end

        context 'role is contributor' do
          let(:role) { 'contributor' }

          specify do
            group_member.update_attributes(role: 'admin')
            update
            expect(response).to redirect_to group_group_members_path(group)
            expect(assigns[:group_member]).to be_contributor
          end
        end

        context 'role is admin' do
          let(:role) { 'admin' }

          specify do
            update
            expect(response).to redirect_to group_group_members_path(group)
            expect(assigns[:group_member]).to be_admin
          end
        end
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:destroy) { delete :destroy, params: { group_id: group.id, id: group_member.id } }

    let(:group_member) { FactoryGirl.create(:group_member, group: group) }

    context 'not logged in' do
      specify do
        destroy
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'logged in' do
      before { sign_in user }

      let(:user) { FactoryGirl.create(:user) }

      context 'not member of group' do
        specify do
          destroy
          expect(response).to redirect_to root_url
        end
      end

      context 'user is invitee' do
        before { FactoryGirl.create(:group_member, :invitee, group: group, user: user) }

        specify do
          destroy
          expect(response).to redirect_to root_url
        end
      end

      context 'user is contributor' do
        before { FactoryGirl.create(:group_member, :contributor, group: group, user: user) }

        specify do
          destroy
          expect(response).to redirect_to group_path(group)
        end
      end

      context 'user is admin' do
        before { FactoryGirl.create(:group_member, :admin, group: group, user: user) }

        specify do
          group_member
          expect(GroupMember.count).to eq 2
          expect(GroupMemberMailer).to receive(:ejection).and_call_original
          destroy
          expect(response).to redirect_to group_group_members_path(group)
          expect(GroupMember.count).to eq 1
        end
      end
    end
  end
end
