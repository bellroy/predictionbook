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

  describe 'callbacks' do
    describe 'before destroy' do
      let(:group) { FactoryGirl.create(:group) }

      before do
        FactoryGirl.create_list(:prediction, 2, :visible_to_group, group_id: group.id)
      end

      specify do
        group.destroy
        expect(Prediction.count).to eq 2
        expect(Prediction.visible_to_creator.where(group_id: nil).count).to eq 2
      end
    end
  end
end
