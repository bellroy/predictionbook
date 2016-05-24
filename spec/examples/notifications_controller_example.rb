require 'spec_helper'

shared_examples_for 'NotificationsController' do
  describe 'redirecting or rendering partial based on xhr? of request' do
    let(:collection) { double('collection') }
    let(:notification) { controller.notification_type.new }

    before(:each) do
      expect(controller).to receive(:notification_collection).and_return(collection)
      sign_in FactoryGirl.create(:user)
    end

    describe 'creating a notification' do
      let(:collection) { double('notifications', create!: notification) }

      it 'redirects to the prediction for non xhr request' do
        expect(notification).to receive(:prediction).and_return(1)
        post :create
        expect(response).to redirect_to(prediction_path(1))
      end

      it 'renders the notification partial for xhr request' do
        xhr :post, :create
        underscored_notification_type = controller.underscored_notification_type
        template_name = "#{underscored_notification_type}s/_#{underscored_notification_type}"
        expect(response).to render_template(template_name)
      end
    end

    describe 'updating a notification' do
      let(:collection) { double('notifications', find: notification) }

      before { expect(notification).to receive(:update_attributes!) }

      it 'redirects to the prediction for non xhr request' do
        expect(notification).to receive(:prediction).and_return(1)
        put :update, id: '1'
        expect(response).to redirect_to(prediction_path(1))
      end

      it 'renders the notification partial for xhr request' do
        xhr :put, :update, id: '1'
        underscored_notification_type = controller.underscored_notification_type
        template_name = "#{underscored_notification_type}s/_#{underscored_notification_type}"
        expect(response).to render_template(template_name)
      end
    end
  end
end
