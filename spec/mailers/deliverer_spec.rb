# encoding: utf-8

require 'spec_helper'

describe Deliverer do
  include Rails.application.routes.url_helpers

  describe 'deadline notification' do
    before :each do
      @deadline_notification = valid_deadline_notification
      @deadline_notification.save
      @deliverer = Deliverer.deadline_notification(@deadline_notification)
    end

    subject { @deliverer }

    it { should have_subject("[PredictionBook] Judgement Day for ‘#{@deadline_notification.description}’") }
    it { should deliver_to(@deadline_notification.email_with_name) }
    it { should reply_to('"PredictionBook" <no-reply@localhost>') }
    it { should deliver_from('"PredictionBook" <no-reply@localhost>') }

    it { should be_multipart }

    context 'html part' do
      subject { @deliverer.html_part.body.to_s }
      it { should include(prediction_url(@deadline_notification.prediction, token: @deadline_notification.uuid)) }
    end

    context 'text part' do
      subject { @deliverer.html_part.body.to_s }
      it { should include(prediction_url(@deadline_notification.prediction, token: @deadline_notification.uuid)) }
    end
  end

  describe 'response notification' do
    before do
      @response_notification = valid_response_notification
      @response_notification.save
      @deliverer = Deliverer.response_notification(@response_notification)
    end

    subject { @deliverer }

    it { should have_subject("[PredictionBook] There has been some activity on ‘#{@response_notification.description}’") }
    it { should deliver_to(@response_notification.email_with_name) }
    it { should reply_to('"PredictionBook" <no-reply@localhost>') }
    it { should deliver_from('"PredictionBook" <no-reply@localhost>') }

    it { should be_multipart }

    context 'html part' do
      subject { @deliverer.html_part.body.to_s }
      it { should include(prediction_url(@response_notification.prediction, token: @response_notification.uuid)) }
    end

    context 'text part' do
      subject { @deliverer.html_part.body.to_s }
      it { should include(prediction_url(@response_notification.prediction, token: @response_notification.uuid)) }
    end
  end
end
