require 'spec_helper'

describe ApplicationController do
  describe 'clearing return_to' do
    it 'should clear return_to session variable before_filter' do
      session[:return_to] = 'blah.url'
      controller.send(:clear_return_to)
      session[:return_to].should be_nil
    end
  end
  describe 'setting timezone before_filter' do
    before(:each) do
      controller.stub!(:logged_in?).and_return(false)
    end
    after(:each) do
      controller.send(:set_timezone)
    end
    describe 'when logged in' do
      before(:each) do
        controller.stub!(:logged_in?).and_return(true)
        controller.stub!(:current_user).and_return(@user = mock_model(User))
      end
      describe 'when user has timezone set' do
        it 'should set Time.zone to current_user.timezone' do
          @user.stub!(:timezone).and_return('Flatland')
          Time.should_receive(:zone=).with('Flatland')
        end
      end
      describe 'when user has no timezone' do
        it 'should set Time.zone to "UTC"' do
          @user.stub!(:timezone).and_return(' ')
          Time.should_receive(:zone=).with('UTC')
        end
      end
    end
    describe 'when not logged in' do
      it 'should set Time.zone to "UTC"' do
        controller.stub!(:logged_in?).and_return(false)
        Time.should_receive(:zone=).with('UTC')
      end
    end
    it "should set Chronic.time_class to Time.zone" do
      Time.stub!(:zone).and_return(:time_zone)
      Chronic.should_receive(:time_class=).with(:time_zone)
    end
  end
  describe 'login via token before_filter' do
    before(:each) do
      controller.stub!(:params).and_return({:token => 'uuid-token'})
      controller.stub!(:redirect_to)
    end
    after(:each) do
      controller.send :login_via_token
    end
    it 'should lookup a DeadlineNotification by uuid' do
      DeadlineNotification.should_receive(:use_token!).with('uuid-token')
    end
    it 'should not lookup if no token in params' do
      DeadlineNotification.should_not_receive(:use_token!)
      controller.stub!(:params).and_return({})
    end
    it 'should set current user to deadline user if found' do
      dn = mock_model(DeadlineNotification, :user => :lazy_user).as_null_object
      DeadlineNotification.stub!(:use_token!).and_yield(dn)
      controller.should_receive(:current_user=).with(:lazy_user)
    end
    it 'should call redirect_to with no args to get rid of the login token' do
      DeadlineNotification.stub!(:use_token!)
      controller.should_receive(:redirect_to).with(no_args)
    end
  end
  describe 'getting the "leaderboard" page' do
    it 'should respond with http success status' do
      get :leaderboard
      response.response_code.should == 200
    end
    it 'should render the leaderboard template' do
      get :leaderboard
      response.should render_template('application/leaderboard')
    end
    it 'should find the list of users for the view' do
      users = mock(:users).as_null_object
      User.should_receive(:limit).with(100).and_return(mock(:collection, :sort_by=> users))
      get :leaderboard
      assigns[:users].should == users 
    end
    it 'should have users sorted in decreasing order of score' do
      users = [1.0, 4.3, 0.7, 1.9, 3.2, 3.0, 0.5, 1.1].map do |score|
        user = mock("user with score #{score}")
        user.stub(:statistics).and_return(mock(:statistics, :score => score))
        user.stub(:eligible_for_leaderboard?).and_return(true)
        user
      end
      User.should_receive(:limit).with(100).and_return(users)
      get :leaderboard
      assigns[:users].each do |user|
        user.statistics.score.should <= score if defined? score
        score = user.statistics.score
      end
    end
    it 'should only have users who have 10 or more judged wagers' do
      users = (0..20).map do |number_of_judged_responses|
        user = mock("user with #{number_of_judged_responses} judged responses")
        user.stub(:number_of_known_responses).and_return(number_of_judged_responses)
        user
      end
      get :leaderboard
      assigns[:users].each do |user|
        user.number_of_known_responses.should >= 10
      end
    end
  end
end
