require 'spec_helper'

describe User do
  it 'should have a name accessor' do
    User.new.should respond_to(:name)
    User.new.should respond_to(:name=)
  end

  it 'should have a private_default field which defaults to false' do
    User.new.private_default.should be false
  end

  it 'should have an email with name' do
    u = User.new(:name => "Tester", :email => "test@test.com")
    u.email_with_name.should == '"Tester" <test@test.com>'
  end

  it "should escape dots in the username with [dot]" do
    User.new(:login => "login.name").to_param.should == "login[dot]name"
  end

  describe 'with lookup by username' do
    it 'should find a user by login' do
      User.should_receive(:find_by_login!).with('login_name').and_return(:user)
      User['login_name'].should == :user
    end

    it 'should replace [dot] in the username with a . when looking up a user' do
      u = User.new(:login => "login.name")
      User.should_receive(:find_by_login!).with("login.name").and_return(u)
      User["login[dot]name"].should == u
    end

    it 'should raise RecordNotFound exception if no user found' do
      lambda { User["login_name"] }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should raise RecordNotFound exception if login is blank' do
      lambda { User[nil] }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'with statistics' do
    it 'should delegate statistics to wagers' do
      user = User.new
      wagers = double('wagers')
      wagers.should_receive(:statistics)
      user.stub(:wagers).and_return(wagers)

      user.statistics
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
      @user.name.should be_nil
    end
    it 'should store email as nil' do
      @user.email = ''
      @user.email.should be_nil
    end
  end

  describe "authorized_for" do
    it "should be true for predictions created by self" do
      @user = User.new
      @prediction = @user.predictions.build(:creator => @user)
      @user.authorized_for(@prediction).should == true
    end
    it "should be false for predictions not created by self" do
      @user = User.new
      @user2 = User.new
      @prediction = @user2.predictions.build(:creator => @user2)
      @user.authorized_for(@prediction).should == false
    end
    it "should be true for admins" do
      @user = User.new
      @user.stub(:admin? => true)
      @user2 = User.new
      @prediction = @user.predictions.build(:creator => @user2)
      @user.authorized_for(@prediction).should == true
    end
  end

  describe "reset password" do
    before do
      @user = User.create!(
        :login                  => "test1",
        :email                  => "test@example.com",
        :password               => "test123",
        :password_confirmation  => "test123"
      )

      UserMailer.stub_chain [:reset_password, :deliver]
    end

    it "should assign a random password" do
      User.authenticate("test1", "test123").should be

      @user.reset_password
      User.authenticate("test1", "test123").should_not be
    end
  end
end
