require 'spec_helper'

RSpec.describe Group, type: :model do
  let(:group) { FactoryGirl.build(:group, name: 'something') }

  describe 'user_role' do
    subject(:user_role) { group.user_role(user) }

    let(:user) { FactoryGirl.create(:user) }

    context 'no membership' do
      it { is_expected.to be_nil }
    end

    context 'is a contributor' do
      before { FactoryGirl.create(:group_member, :contributor, group: group, user: user) }
      it { is_expected.to eq 'contributor' }
    end

    context 'is an admin' do
      before { FactoryGirl.create(:group_member, :admin, group: group, user: user) }
      it { is_expected.to eq 'admin' }
    end
  end
end
