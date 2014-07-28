require 'spec_helper'

describe UsersController do
  before(:each) do
    @user = mock_model(User).as_null_object
    User.stub(:[]).and_return(@user)
    controller.stub(:set_timezone)
    controller.stub(:current_user).and_return(@user)
  end

  describe 'showing a users prediction page (GET:show)' do
    def show
      get :show, :id => 'adam'
    end
    it 'should lookup the user by [] lookup' do
      User.should_receive(:[]).and_return(@user)
      show
    end
    it 'should get all the recent predictions by user name' do
      @user.should_receive(:predictions).and_return double(Array, :limit => double(Array, :not_private => []))
      show
    end
    it 'should limit the scope to not_private predictions if not logged in as the user of the page' do
      controller.stub(:current_user).and_return :eve
      @user.stub(:predictions).and_return double(Array, :limit => predictions =  [])
      predictions.should_receive(:not_private).and_return predictions

      show
      assigns[:predictions].should == predictions
    end
    it 'should not limit the scope if current_user is owner of page' do
      controller.stub(:current_user).and_return @user
      @user.stub(:predictions).and_return double(Array, :limit => predictions = double(Array))

      show
      assigns[:predictions].should == predictions
    end
    it 'should assign the predictions' do
      @user.stub(:predictions).and_return(double(Array, :limit => predictions = []))
      show
      assigns[:predictions].should == predictions
    end
    it 'should assign the user' do
      show
      assigns[:user].should == @user
    end
  end

  describe 'statistics accessor' do
    before(:each) do
      controller.instance_variable_set('@user', @user)
    end
    it 'should provide a statistics accessor' do
      controller.should respond_to(:statistics)
    end

    it 'should delegate to the statistics to the user' do
      @user.should_receive(:statistics)
      controller.statistics
    end

    it 'should return the statistics from the user' do
      @user.stub(:statistics).and_return(:stats)
      controller.statistics.should == :stats
    end
  end

  describe 'users setting page' do
    before(:each) do
      controller.stub(:logged_in?).and_return(true)
    end
    def show
      get :settings, :id => 'adam'
    end
    it 'should require the user to be logged in' do
      controller.stub(:logged_in?).and_return(false)
      show
      response.should redirect_to(login_path)
    end
    it 'should 403 on user if they are not the described user' do
      controller.stub(:current_user).and_return(mock_model(User))
      show
      response.response_code.should == 403
    end
    it 'should render if passed authentication' do
      controller.stub(:current_user).and_return(@user)
      show
      response.should be_success
    end
    it 'should assign user' do
      show
      assigns[:user].should == @user
    end
  end
end
