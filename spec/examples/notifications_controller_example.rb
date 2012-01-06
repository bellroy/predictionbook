require 'spec_helper'

shared_examples_for 'NotificationsController' do
  describe 'redirecting or rendering partial based on xhr? of request' do
    before(:each) do
      controller.stub!(:notification_collection).and_return(@collection = mock('collection'))
      controller.stub!(:login_required)
    end

    describe 'creating a notification' do
      before(:each) do
        @notification = mock('notification').as_null_object
        collection = mock('notifications', :create! => @notification)
        controller.stub!(:notification_collection).and_return(collection)
      end
      it 'should ask if is xhr?' do
        request.should_receive(:xhr?)
        post :create
      end
      it 'should redirect to the prediction' do
        request.stub!(:xhr?).and_return false
        @notification.stub!(:prediction).and_return(1)
        post :create
        response.should redirect_to(prediction_path(1))
      end
      it 'should render the notification partial if xhr' do
        request.stub!(:xhr?).and_return true
        controller.should_receive(:render).with(:partial => @notification)
        post :create
      end
    end
  
    describe 'updating a notification' do
      before(:each) do
        @notification = mock('notification').as_null_object
        collection = mock('notifications', :find => @notification)
        controller.stub!(:notification_collection).and_return(collection)
      end
      it 'should ask if is xhr?' do
        request.should_receive(:xhr?)
        put :update, :id => '1'
      end
      it 'should redirect to the prediction' do
        request.stub!(:xhr?).and_return false
        @notification.stub!(:prediction).and_return(1)
        put :update, :id => '1'
        response.should redirect_to(prediction_path(1))
      end
      it 'should render the notification partial if xhr' do
        request.stub!(:xhr?).and_return true
        controller.should_receive(:render).with(:partial => @notification)
        put :update, :id => '1'
      end
    end
  end
end
