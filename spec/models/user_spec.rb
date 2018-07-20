require 'spec_helper'

describe User do
  it 'has a name accessor' do
    expect(User.new).to respond_to(:name)
    expect(User.new).to respond_to(:name=)
  end

  it 'has a private_default field which defaults to false' do
    expect(User.new.visible_to_everyone?).to be true
  end

  it 'has an email with name' do
    u = User.new(name: 'Tester', email: 'test@test.com')
    expect(u.email_with_name).to eq '"Tester" <test@test.com>'
  end

  it 'should escape dots in the username with [dot]' do
    expect(User.new(login: 'login.name').to_param).to eq 'login[dot]name'
  end

  describe 'with statistics' do
    it 'should delegate statistics to wagers' do
      user = User.new
      user.id = 123
      stats = double(Statistics)
      expect(Statistics).to receive(:new).with('r.user_id = 123').and_return(stats)
      expect(user.statistics).to eq stats
    end
  end

  describe 'when given empty string' do
    before(:each) do
      @user = User.new
    end
    it 'should store empty name as nil' do
      @user.name = " \t \n "
      expect(@user.name).to be_nil
    end
    it 'should store email as nil' do
      @user.email = ''
      expect(@user.email).to be_nil
    end
  end

  describe 'authorized_for?' do
    subject { user.authorized_for?(prediction, action) }

    let(:user) { User.new }
    let(:creator_user) { user }
    let(:action) { 'edit' }
    let(:prediction) do
      user.predictions.build(creator: creator_user, visibility: :visible_to_creator)
    end

    it { is_expected.to be true }

    context 'not created by user' do
      let(:creator_user) { User.new }

      it { is_expected.to be false }

      context 'user is admin' do
        let(:user) { User.new(login: 'matt') }
        let(:creator_user) { User.new }

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
