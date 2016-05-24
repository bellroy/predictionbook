require 'spec_helper'

describe DeadlineNotification do
  describe 'class method' do
    describe 'named routes' do
      # have to hit the DB, named_routes rely on SQL
      describe 'unsent' do
        it 'finds all unsent' do
          unsent = DeadlineNotification.new(sent: false)
          unsent.save(validate: false)
          DeadlineNotification.new(sent: true).save(validate: false)

          expect(DeadlineNotification.unsent).to eq [unsent]
        end
      end

      describe 'sendable' do
        it 'filters to having email and judgement due' do
          dns = instance_double(DeadlineNotification).as_null_object
          expect(dns).to receive(:sendable?)
          expect(DeadlineNotification).to receive(:unsent).and_return([dns])

          DeadlineNotification.sendable
        end
      end
    end

    describe 'notify overdue unsent' do
      it 'sends notification emails for all unsent and overdue' do
        user = FactoryGirl.create(:user)
        prediction = FactoryGirl.create(:prediction, deadline: 2.days.ago, creator: user)
        dn = prediction.deadline_notifications.first
        dn.update_attributes!(enabled: true, sent: false)
        DeadlineNotification.send_all!
        expect(dn.reload).to be_sent
      end

      it 'should not send notification emails for pending notifications' do
        user = FactoryGirl.create(:user)
        prediction = FactoryGirl.create(:prediction, deadline: 2.days.from_now, creator: user)
        prediction.save!
        dn = prediction.deadline_notifications.first
        dn.update_attributes!(enabled: true, sent: false)
        DeadlineNotification.send_all!
        expect(dn.reload).not_to be_sent
      end
    end
  end

  describe 'instance method' do
    let(:notification) { FactoryGirl.create(:deadline_notification) }

    describe 'deliver!' do
      it 'calls deliver and update sent' do
        expect(notification).to receive(:deliver)
        expect(notification).to receive(:update_attribute).with(:sent, true)
        notification.deliver!
      end
    end

    describe 'deliver' do
      it 'should do the actual mailer stuff' do
        mailer = instance_double(ActionMailer::MessageDelivery)
        expect(mailer).to receive(:deliver_now)
        expect(Deliverer).to receive(:deadline_notification).with(notification).and_return(mailer)
        notification.deliver
      end
    end

    describe 'sendable?' do
      subject { notification.sendable? }

      let(:notification) { DeadlineNotification.new }
      let(:has_email) { true }
      let(:due_for_judgement) { true }
      let(:enabled) { true }
      let(:withdrawn) { false }

      before(:each) do
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
