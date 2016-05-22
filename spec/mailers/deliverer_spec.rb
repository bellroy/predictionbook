# encoding: utf-8

require 'spec_helper'

describe Deliverer do
  include Rails.application.routes.url_helpers

  describe 'deadline notification' do
    let(:notification) { FactoryGirl.create(:deadline_notification) }
    let(:deliverer) { Deliverer.deadline_notification(notification) }

    subject { deliverer }

    specify do
      is_expected.to have_subject "[PredictionBook] Judgement Day for ‘#{notification.description}’"
    end
    it { is_expected.to deliver_to(notification.email_with_name) }
    it { is_expected.to reply_to('"PredictionBook" <no-reply@localhost>') }
    it { is_expected.to deliver_from('"PredictionBook" <no-reply@localhost>') }

    it { is_expected.to be_multipart }

    context 'html part' do
      subject { deliverer.html_part.body.to_s }
      specify do
        is_expected.to include(prediction_url(notification.prediction, token: notification.uuid))
      end
    end

    context 'text part' do
      subject { deliverer.html_part.body.to_s }
      specify do
        is_expected.to include(prediction_url(notification.prediction, token: notification.uuid))
      end
    end
  end

  describe 'response notification' do
    let(:notification) { FactoryGirl.create(:response_notification) }
    let(:deliverer) { Deliverer.response_notification(notification) }

    subject { deliverer }

    specify do
      email_subj = "[PredictionBook] There has been some activity on ‘#{notification.description}’"
      is_expected.to have_subject email_subj
    end
    it { is_expected.to deliver_to(notification.email_with_name) }
    it { is_expected.to reply_to('"PredictionBook" <no-reply@localhost>') }
    it { is_expected.to deliver_from('"PredictionBook" <no-reply@localhost>') }

    it { is_expected.to be_multipart }

    context 'html part' do
      subject { deliverer.html_part.body.to_s }
      specify do
        is_expected.to include(prediction_url(notification.prediction, token: notification.uuid))
      end
    end

    context 'text part' do
      subject { deliverer.html_part.body.to_s }
      specify do
        is_expected.to include(prediction_url(notification.prediction, token: notification.uuid))
      end
    end
  end
end
