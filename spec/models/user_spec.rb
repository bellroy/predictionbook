# frozen_string_literal: true

require 'spec_helper'

describe User do
  it 'has a name accessor' do
    expect(described_class.new).to respond_to(:name)
    expect(described_class.new).to respond_to(:name=)
  end

  it 'has a private_default field which defaults to false' do
    expect(described_class.new.visible_to_everyone?).to be true
  end

  it 'has an email with name' do
    u = described_class.new(name: 'Tester', email: 'test@test.com')
    expect(u.email_with_name).to eq '"Tester" <test@test.com>'
  end

  it 'escapes dots in the username with [dot]' do
    expect(described_class.new(login: 'login.name').to_param).to eq 'login[dot]name'
  end

  describe 'with statistics' do
    it 'delegates statistics to wagers' do
      user = described_class.new
      user.id = 123
      stats = double(Statistics)
      expect(Statistics).to receive(:new).with('r.user_id = 123').and_return(stats)
      expect(user.statistics).to eq stats
    end
  end

  describe 'when given empty string' do
    before do
      @user = described_class.new
    end

    it 'stores empty name as nil' do
      @user.name = " \t \n "
      expect(@user.name).to be_nil
    end
    it 'stores email as nil' do
      @user.email = ''
      expect(@user.email).to be_nil
    end
  end

  describe 'authorized_for?' do
    subject { user.authorized_for?(prediction, action) }

    let(:user) { described_class.new }
    let(:creator_user) { user }
    let(:action) { 'edit' }
    let(:prediction) do
      user.predictions.build(creator: creator_user, visibility: :visible_to_creator)
    end

    it { is_expected.to be true }

    context 'not created by user' do
      let(:creator_user) { described_class.new }

      it { is_expected.to be false }

      context 'user is admin' do
        let(:user) { described_class.new(admin: true) }
        let(:creator_user) { described_class.new }

        it { is_expected.to be true }
      end

      context 'prediction in group' do
        let(:group) { FactoryBot.create(:group) }
        let(:prediction) do
          user.predictions.build(creator: creator_user, visibility: :visible_to_group, group: group)
        end
        let(:action) { 'show' }
        let(:user) { FactoryBot.create(:user) }

        context 'user in group' do
          before do
            FactoryBot.create(:group_member, role, group: group, user: user)
          end

          let(:role) { :contributor }

          it { is_expected.to be true }

          context 'editing' do
            let(:action) { 'edit' }

            it { is_expected.to be false }

            context 'user is admin' do
              let(:role) { :admin }

              it { is_expected.to be true }
            end
          end
        end

        context 'user not in group' do
          before { group }

          it { is_expected.to be false }
        end
      end
    end
  end
end
