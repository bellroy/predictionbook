# frozen_string_literal: true

require 'spec_helper'

describe Deliverer do
  include Rails.application.routes.url_helpers

  describe 'deadline notification' do
    subject { deliverer }

    let(:notification) { FactoryBot.create(:deadline_notification) }
    let(:deliverer) { described_class.deadline_notification(notification) }

    specify do
      expect(subject).to have_subject "[PredictionBook] Judgement Day for ‘#{notification.description}’"
    end
    it 'works', :aggregate_failures do
      expect(subject).to deliver_to(notification.email_with_name)
      expect(subject).to reply_to('"PredictionBook" <no-reply@localhost>')
      expect(subject).to deliver_from('"PredictionBook" <no-reply@localhost>')
      expect(subject).to be_multipart
    end

    context 'html part' do
      subject { deliverer.html_part.body.to_s }

      specify do
        expect(subject).to include(prediction_url(notification.prediction, token: notification.uuid))
      end
    end

    context 'text part' do
      subject { deliverer.html_part.body.to_s }

      specify do
        expect(subject).to include(prediction_url(notification.prediction, token: notification.uuid))
      end
    end
  end

  describe 'response notification' do
    subject { deliverer }

    let(:notification) { FactoryBot.create(:response_notification) }
    let(:deliverer) { described_class.response_notification(notification) }

    specify do
      email_subj = "[PredictionBook] There has been some activity on ‘#{notification.description}’"
      expect(subject).to have_subject email_subj
    end
    it 'works', :aggregate_failures do
      expect(subject).to deliver_to(notification.email_with_name)
      expect(subject).to reply_to('"PredictionBook" <no-reply@localhost>')
      expect(subject).to deliver_from('"PredictionBook" <no-reply@localhost>')
      expect(subject).to be_multipart
    end

    context 'html part' do
      subject { deliverer.html_part.body.to_s }

      specify do
        expect(subject).to include(prediction_url(notification.prediction, token: notification.uuid))
      end
    end

    context 'text part' do
      subject { deliverer.html_part.body.to_s }

      specify do
        expect(subject).to include(prediction_url(notification.prediction, token: notification.uuid))
      end
    end
  end
end
