require 'spec_helper'

describe User do
  it 'has a name accessor' do
    expect(User.new).to respond_to(:name)
    expect(User.new).to respond_to(:name=)
  end

  it 'has a private_default field which defaults to false' do
    expect(User.new.private_default).to be false
  end

  it 'has an email with name' do
    u = User.new(name: 'Tester', email: 'test@test.com')
    expect(u.email_with_name).to eq '"Tester" <test@test.com>'
  end

  it 'should escape dots in the username with [dot]' do
    expect(User.new(login: 'login.name').to_param).to eq 'login[dot]name'
  end

  describe 'with lookup by username' do
    it 'finds a user by login' do
      expect(User).to receive(:find_by_login!).with('login_name').and_return(:user)
      expect(User['login_name']).to eq :user
    end

    it 'should replace [dot] in the username with a . when looking up a user' do
      u = User.new(login: 'login.name')
      expect(User).to receive(:find_by_login!).with('login.name').and_return(u)
      expect(User['login[dot]name']).to eq u
    end

    it 'should raise RecordNotFound exception if no user found' do
      expect { User['login_name'] }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should raise RecordNotFound exception if login is blank' do
      expect { User[nil] }.to raise_error(ActiveRecord::RecordNotFound)
    end
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

  describe 'predictions' do
    before do
      # This will require a lot of stubbing, user, predicitons [sic], responses... Oh my!?
    end
    it 'should order by when wager was made, most recent first'
    it 'should not contain the same prediction twice, even if I have wagered twice'
    it 'should not contain predictions I have only commented on'
    it 'should not contain predictions I have no wager on'
    it 'should include predictions I have wagered on'
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

  describe 'authorized_for' do
    it 'is true for predictions created by self' do
      @user = User.new
      @prediction = @user.predictions.build(creator: @user)
      expect(@user.authorized_for(@prediction)).to eq true
    end
    it 'is false for predictions not created by self' do
      @user = User.new
      @user2 = User.new
      @prediction = @user2.predictions.build(creator: @user2)
      expect(@user.authorized_for(@prediction)).to eq false
    end
    it 'is true for admins' do
      @user = User.new
      expect(@user).to receive(:admin?).and_return(true)
      @user2 = User.new
      @prediction = @user.predictions.build(creator: @user2)
      expect(@user.authorized_for(@prediction)).to eq true
    end
  end
end
