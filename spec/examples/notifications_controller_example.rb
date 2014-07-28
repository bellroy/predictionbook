require 'spec_helper'

shared_examples_for 'NotificationsController' do
  describe 'redirecting or rendering partial based on xhr? of request' do
    before(:each) do
      controller.stub(:notification_collection).and_return(@collection = double('collection'))
      controller.stub(:login_required)
    end

    describe 'creating a notification' do
      before(:each) do
        @notification = controller.notification_type.new
        collection = double('notifications', :create! => @notification)
        controller.stub(:notification_collection).and_return(collection)
      end
      it 'should redirect to the prediction for non xhr request' do
        @notification.stub(:prediction).and_return(1)
        post :create
        response.should redirect_to(prediction_path(1))
      end
      it 'should render the notification partial for xhr request' do
        xhr :post, :create
        response.should render_template("#{controller.notification}s/_#{controller.notification}")
      end
    end

    describe 'updating a notification' do
      before(:each) do
        @notification = controller.notification_type.new
        @notification.stub(:update_attributes!)
        collection = double('notifications', :find => @notification)
        controller.stub(:notification_collection).and_return(collection)
      end

      it 'should redirect to the prediction for non xhr request' do
        @notification.stub(:prediction).and_return(1)
        put :update, :id => '1'
        response.should redirect_to(prediction_path(1))
      end
      it 'should render the notification partial for xhr request' do
        xhr :put, :update, :id => '1'
        response.should render_template("#{controller.notification}s/_#{controller.notification}")
      end
    end
  end
end
