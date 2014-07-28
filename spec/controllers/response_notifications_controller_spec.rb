require 'spec_helper'

describe ResponseNotificationsController do
  before(:each) do
    controller.stub(:set_timezone)
  end
  describe 'creating a notification' do
    it 'should require the user to be logged in' do
      post :create
      response.should redirect_to(login_path)
    end
    describe 'when logged in' do
      before(:each) do
        controller.stub(:login_required)
        controller.stub(:notification_collection).and_return(@collection = double('collection'))
      end
      it 'should create a response notification record' do
        notification = mock_model(ResponseNotification).as_null_object
	notification.stub(:prediction).and_return(mock_model(Prediction,:id => 1))
        @collection.should_receive(:create!).with('prediction_id' => '7').and_return(notification)
        post :create, :response_notification => {:prediction_id => '7'}
      end
      it 'should redirect back to the prediction' do
        @collection.stub(:create!).and_return(mock_model(ResponseNotification, :prediction => mock_model(Prediction, :id => '7')))
        post :create
        response.should redirect_to(prediction_path('7'))
      end
    end
  end

  describe 'updating a notification' do
    it 'should require the user to be logged in' do
      put :update, :id => 'hai'
      response.should redirect_to(login_path)
    end
    describe 'when logged in' do
      before(:each) do
        controller.stub(:login_required)
        controller.stub(:notification_collection).and_return(collection = double('collection'))
        collection.stub(:find).and_return(@notification = mock_model(ResponseNotification).as_null_object)
        @notification.stub(:prediction).and_return(mock_model(Prediction, :id => '7'))
      end
      it 'should update a response notification record' do
        @notification.should_receive(:update_attributes!)
        put :update, :id => 'hai', :response_notification => {:prediction_id => '7'}
      end
      it 'should redirect back to the prediction' do
        put :update, :id => 'hai'
        response.should redirect_to(prediction_path('7'))
      end
    end
  end

  describe 'notification collection accessor' do
    it 'should ask the current user for its response_notifications' do
      controller.stub(:current_user).and_return(user = mock_model(User))
      user.should_receive(:response_notifications)
      controller.notification_collection
    end
  end
end
