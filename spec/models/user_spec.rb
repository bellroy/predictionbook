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
