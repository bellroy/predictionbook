# frozen_string_literal: true

require 'spec_helper'

describe GroupMemberInvitationsController do
  let(:group_member) { FactoryGirl.create(:group_member, :invitee) }
  let(:group) { group_member.group }

  describe 'GET show' do
    subject(:show) { get :show, params }

    context 'valid group invitation' do
      let(:params) { { id: group_member.uuid } }

      specify do
        show
        expect(response).to redirect_to root_url
        expect(group_member.reload).to be_contributor
        expect(flash[:notice]).to eq "You are now a contributing member of the #{group.name} group"
      end
    end

    context 'invalid group invitation' do
      let(:params) { { id: 'abcdef' } }

      specify do
        expect { show }.not_to change { group_member.reload.role }
        expect(response).to redirect_to root_url
        expect(flash[:notice]).to be_nil
      end
    end
  end
end
