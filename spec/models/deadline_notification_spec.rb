# frozen_string_literal: true

require 'spec_helper'

describe DeadlineNotification do
  describe 'class method' do
    describe 'named routes' do
      # have to hit the DB, named_routes rely on SQL
      describe 'unsent' do
        it 'finds all unsent' do
          unsent = described_class.new(sent: false)
          unsent.save(validate: false)
          described_class.new(sent: true).save(validate: false)

          expect(described_class.unsent).to eq [unsent]
        end
      end

      describe 'sendable' do
        it 'filters to having email and judgement due' do
          dns = instance_double(described_class).as_null_object
          expect(dns).to receive(:sendable?)
          expect(described_class).to receive(:unsent).and_return([dns])

          described_class.sendable
        end
      end
    end

    describe 'notify overdue unsent' do
      it 'sends notification emails for all unsent and overdue' do
        user = FactoryBot.create(:user)
        prediction = FactoryBot.create(:prediction, deadline: 2.days.ago, creator: user)
        dn = prediction.deadline_notifications.first
        dn.update!(enabled: true, sent: false)
        described_class.send_all!
        expect(dn.reload).to be_sent
      end

      it 'does not send notification emails for pending notifications' do
        user = FactoryBot.create(:user)
        prediction = FactoryBot.create(:prediction, deadline: 2.days.from_now, creator: user)
        prediction.save!
        dn = prediction.deadline_notifications.first
        dn.update!(enabled: true, sent: false)
        described_class.send_all!
        expect(dn.reload).not_to be_sent
      end
    end
  end

  describe 'instance method' do
    let(:notification) { FactoryBot.create(:deadline_notification) }

    describe 'deliver!' do
      it 'calls deliver and update sent' do
        expect(notification).to receive(:deliver)
        expect(notification).to receive(:update_attribute).with(:sent, true)
        notification.deliver!
      end
    end

    describe 'deliver' do
      it 'does the actual mailer stuff' do
        mailer = instance_double(ActionMailer::MessageDelivery)
        expect(mailer).to receive(:deliver_now)
        expect(Deliverer).to receive(:deadline_notification).with(notification).and_return(mailer)
        notification.deliver
      end
    end

    describe 'sendable?' do
      subject { notification.sendable? }

      let(:notification) { described_class.new }
      let(:has_email) { true }
      let(:due_for_judgement) { true }
      let(:enabled) { true }
      let(:withdrawn) { false }

      before do
        allow(notification).to receive(:has_email?).and_return(has_email)
        allow(notification).to receive(:due_for_judgement?).and_return(due_for_judgement)
        allow(notification).to receive(:enabled?).and_return(enabled)
        allow(notification).to receive(:withdrawn?).and_return(withdrawn)
      end

      it { is_expected.to be true }

      context 'does not have email' do
        let(:has_email) { false }

        it { is_expected.to be false }

        context 'is not enabled' do
          let(:enabled) { false }

          it { is_expected.to be false }

          context 'not due for judgement' do
            let(:due_for_judgement) { false }

            it { is_expected.to be false }
          end
        end

        context 'not due for judgement' do
          let(:due_for_judgement) { false }

          it { is_expected.to be false }
        end
      end

      context 'not due for judgement' do
        let(:due_for_judgement) { false }

        it { is_expected.to be false }

        context 'is not enabled' do
          let(:enabled) { false }

          it { is_expected.to be false }
        end
      end

      context 'withdrawn' do
        let(:withdrawn) { true }

        it { is_expected.to be false }
      end
    end
  end
end
