require 'spec_helper'

describe DeadlineNotificationsController do
  it_should_behave_like 'NotificationsController'
  def get_index
    get :index, :user_id => 'glenn'
  end
  before do
    User.stub(:[]).with('glenn').and_return(User.new)
    controller.stub(:set_timezone)
  end
  describe 'index' do
    before(:each) do
      controller.stub(:login_required)
    end
    it 'should render ok' do
      get_index
      response.response_code.should == 200
    end

    [:pending, :waiting, :known, :sent].each do |scope|
      it "should assign #{scope}" do
        get_index
        assigns[scope].should_not be_nil
      end
    end

  end

  describe 'create' do
    it 'should require login' do
      post :create
      response.should redirect_to(login_path)
    end
    describe 'logged in' do
      before do
        controller.stub(:logged_in?).and_return true
        controller.stub(:current_user).and_return(user = mock_model(User))
        controller.stub(:notification_collection).and_return(@collection = double('collection'))
      end
      it 'should create one' do
        notification = mock_model(ResponseNotification).as_null_object
	      notification.stub(:prediction).and_return(mock_model(Prediction,:id => 1))
        @collection.should_receive(:create!).with('prediction_id' => '7').and_return(notification)
        post :create, :deadline_notification => {:prediction_id => '7'}
      end
      it "should redirect to the prediction_path of it's prediction" do
        @collection.stub(:create!).and_return(mock_model(DeadlineNotification, :prediction => mock_model(Prediction, :id => '7')))
        post :create
        response.should redirect_to(prediction_path('7'))
      end
    end
  end

  describe 'update' do
    it 'should require login' do
      put :update, :id => '1'
      response.should redirect_to(login_path)
    end
    describe 'logged in' do
      before do
        controller.stub(:logged_in?).and_return true
        @notification = mock_model(DeadlineNotification).as_null_object
        @notification.stub(:prediction).and_return(mock_model(Prediction, :id => '7'))
        controller.stub(:current_user).and_return(user = mock_model(User))
        controller.stub(:notification_collection).and_return(collection = double('collection'))
        collection.stub(:find).and_return(@notification)
      end
      it 'should modify the notification' do
        @notification.should_receive(:update_attributes!).with('enabled' => '1')

        put :update, :id => '1', :deadline_notification => { :enabled => '1' }
      end
      it "should redirect to the prediction_path of it's prediction" do
        put :update, :id => '1'
        response.should redirect_to(prediction_path('7'))
      end
    end
  end

  describe 'notification collection accessor' do
    it 'should ask the current user for its deadline_notifications' do
      controller.stub(:current_user).and_return(user = mock_model(User))
      user.should_receive(:deadline_notifications)
      controller.notification_collection
    end
  end
end
