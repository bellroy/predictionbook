require 'spec_helper'

describe ResponseNotificationsController do
  before(:each) do
    expect(controller).to receive(:set_timezone)
  end

  describe 'creating a notification' do
    it 'requires the user to be logged in' do
      post :create
      expect(response).to redirect_to(new_user_session_path)
    end

    describe 'when logged in' do
      let(:relation) { instance_double(ActiveRecord::Relation) }

      before(:each) do
        sign_in FactoryBot.create(:user)
        expect_any_instance_of(User).to receive(:response_notifications).and_return(relation)
      end

      it 'creates a response notification record' do
        notification = instance_double(ResponseNotification).as_null_object
        expect(notification).to receive(:prediction).and_return(instance_double(Prediction, id: 1))
        expect(relation).to receive(:create!).with('prediction_id' => '7').and_return(notification)
        post :create, params: { response_notification: { prediction_id: '7' } }
      end

      it 'redirects back to the prediction' do
        prediction = instance_double(Prediction, id: '7')
        response_notification = instance_double(ResponseNotification, prediction: prediction)
        expect(relation).to receive(:create!).and_return(response_notification)
        post :create, params: { response_notification: { prediction_id: '7' } }
        expect(response).to redirect_to(prediction_path(prediction))
      end
    end
  end

  describe 'updating a notification' do
    it 'requires the user to be logged in' do
      put :update, params: { id: 'hai' }
      expect(response).to redirect_to(new_user_session_path)
    end

    describe 'when logged in' do
      let(:notification) { instance_double(ResponseNotification).as_null_object }
      let(:relation) { instance_double(ActiveRecord::Relation) }
      let(:prediction) { instance_double(Prediction, id: '7') }

      before(:each) do
        sign_in FactoryBot.create(:user)
        expect_any_instance_of(User).to receive(:response_notifications).and_return(relation)
        expect(relation).to receive(:find).and_return(notification)
        expect(notification).to receive(:prediction).and_return(prediction)
      end

      it 'updates a response notification record' do
        expect(notification).to receive(:update_attributes!)
        put :update, params: { id: 'hai', response_notification: { prediction_id: '7' } }
      end

      it 'redirects back to the prediction' do
        put :update, params: { id: 'hai', response_notification: { prediction_id: '7' } }
        expect(response).to redirect_to(prediction_path(prediction))
      end
    end
  end
end
