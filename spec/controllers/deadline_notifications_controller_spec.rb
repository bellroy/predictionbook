# frozen_string_literal: true

require 'spec_helper'

describe DeadlineNotificationsController do
  it_behaves_like 'NotificationsController'

  describe 'index' do
    let(:user) { FactoryBot.create(:user) }
    before { sign_in user }

    subject(:get_index) { get :index, params: { user_id: user.id } }

    it 'renders ok' do
      get_index
      expect(response.response_code).to eq 200
    end

    %i[pending waiting known sent].each do |scope|
      it "assigns #{scope}" do
        get_index
        expect(assigns[scope]).not_to be_nil
      end
    end
  end

  describe 'create' do
    it 'requires login' do
      post :create
      expect(response).to redirect_to(new_user_session_path)
    end

    describe 'logged in' do
      before do
        sign_in FactoryBot.create(:user)
        @collection = double('collection')
        expect(controller).to receive(:notification_collection).and_return(@collection)
      end

      it 'creates one' do
        notification = mock_model(ResponseNotification).as_null_object
        expect(notification).to receive(:prediction).and_return(mock_model(Prediction, id: 1))
        expect(@collection)
          .to receive(:create!).with(hash_including('prediction_id': '7')).and_return(notification)
        post :create, params: { deadline_notification: { prediction_id: '7' } }
      end

      it "redirects to the prediction_path of it's prediction" do
        prediction = mock_model(Prediction, id: '7')
        deadline_notification = mock_model(DeadlineNotification, prediction: prediction)
        expect(@collection).to receive(:create!).and_return(deadline_notification)
        post :create, params: { deadline_notification: { prediction_id: '7', enabled: '1' } }
        expect(response).to redirect_to(prediction_path('7'))
      end
    end
  end

  describe 'update' do
    it 'requires login' do
      put :update, params: { id: '1', deadline_notification: { enabled: '1' } }
      expect(response).to redirect_to(new_user_session_path)
    end

    describe 'logged in' do
      before do
        sign_in FactoryBot.create(:user)
        @notification = mock_model(DeadlineNotification).as_null_object
        expect(@notification).to receive(:prediction).and_return(mock_model(Prediction, id: '7'))
        collection = double('collection')
        expect(controller).to receive(:notification_collection).and_return(collection)
        expect(collection).to receive(:find).and_return(@notification)
      end

      it 'modifies the notification' do
        expect(@notification).to receive(:update_attributes!).with('enabled' => '1')

        put :update, params: { id: '1', deadline_notification: { enabled: '1' } }
      end

      it "redirects to the prediction_path of it's prediction" do
        put :update, params: { id: '1', deadline_notification: { enabled: '1' } }
        expect(response).to redirect_to(prediction_path('7'))
      end
    end
  end

  describe 'notification collection accessor' do
    it 'asks the current user for its deadline_notifications' do
      user = FactoryBot.create(:user)
      sign_in user
      expect_any_instance_of(User).to receive(:deadline_notifications)
      controller.notification_collection
    end
  end
end
