require 'spec_helper'

describe ApplicationController do
  describe 'clearing return_to' do
    it 'clears return_to session variable before_filter' do
      session[:return_to] = 'blah.url'
      controller.send(:clear_return_to)
      expect(session[:return_to]).to be_nil
    end
  end

  describe 'setting timezone before_filter' do
    describe 'when logged in' do
      let(:user) { FactoryBot.create(:user, timezone: timezone) }

      before { sign_in user if user.present? }

      describe 'when user has timezone set' do
        let(:timezone) { 'Flatland' }

        it 'sets Time.zone to current_user.timezone' do
          expect(Time).to receive(:zone=).with('Flatland')
          expect(Chronic).to receive(:time_class=)
          controller.send(:set_timezone)
        end
      end

      describe 'when user has no timezone' do
        let(:timezone) { nil }

        it 'sets Time.zone to "UTC"' do
          expect(Time).to receive(:zone=).with('UTC')
          expect(Chronic).to receive(:time_class=)
          controller.send(:set_timezone)
        end
      end
    end

    describe 'when not logged in' do
      let(:user) { nil }

      it 'sets Time.zone to "UTC"' do
        expect(Time).to receive(:zone=).with('UTC')
        expect(Chronic).to receive(:time_class=)
        controller.send(:set_timezone)
      end
    end
  end

  describe 'login via token before_filter' do
    before { expect(controller).to receive(:params).and_return(params) }

    context 'no token in params' do
      let(:params) { {} }

      it 'does not lookup if no token in params' do
        expect(DeadlineNotification).not_to receive(:use_token!)
        controller.send :login_via_token
      end
    end

    context 'token in params' do
      let(:params) { { token: 'uuid-token' } }

      before { expect(controller).to receive(:redirect_to) }

      it 'looks up a DeadlineNotification by uuid' do
        expect(DeadlineNotification).to receive(:use_token!).with('uuid-token')
        controller.send :login_via_token
      end

      it 'sets current user to deadline user if found' do
        dn = instance_double(DeadlineNotification, user: :lazy_user).as_null_object
        expect(DeadlineNotification).to receive(:use_token!).and_yield(dn)
        controller.send :login_via_token
        expect(assigns[:current_user]).to eq :lazy_user
      end
    end
  end
end
