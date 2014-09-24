require 'spec_helper'

describe DeadlineNotification do
  describe 'class method' do
    describe 'named routes' do
      # have to hit the DB, named_routes rely on SQL
      describe 'unsent' do
        it 'should find all unsent' do
          unsent = DeadlineNotification.new(:sent => false)
          unsent.save(:validate=> false)
          DeadlineNotification.new(:sent => true).save(:validate=> false)

          DeadlineNotification.unsent.should == [unsent]
        end
      end
      describe 'sendable' do
        it 'should filter to having email and judgement due' do
          dns = double('dns').as_null_object
          dns.should_recieve(:sendable?)
          DeadlineNotification.should_receive(:unsent).and_return(dns)

          DeadlineNotification.sendable
        end
      end
    end
    describe 'notify overdue unsent' do
      it 'should send notification emails for all unsent and overdue' do
        user = build(:user_with_email)
        prediction = build(:prediction, :deadline => 2.days.ago, :creator => user)
        prediction.save!
        dn = prediction.deadline_notifications.first
        dn.update_attributes!(:enabled => true, :sent => false)
        DeadlineNotification.send_all!
        dn.reload.should be_sent
      end
      it 'should not send notification emails for pending notifications' do
        user = build(:user_with_email)
        prediction = build(:prediction, :deadline => 2.days.from_now, :creator => user)
        prediction.save!
        dn = prediction.deadline_notifications.first
        dn.update_attributes!(:enabled => true, :sent => false)
        DeadlineNotification.send_all!
        dn.reload.should_not be_sent
      end
    end
  end

  describe 'instance method' do
    before(:each) do
      @dn = DeadlineNotification.new
    end
    describe 'deliver!' do
      it 'should call deliver and update sent' do
        @dn.should_receive(:deliver)
        @dn.should_receive(:update_attribute).with(:sent, true)
        @dn.deliver!
      end
    end
    describe 'deliver' do
      it 'should do the actual mailer stuff' do
        mailer = double :mail
        mailer.should_receive(:deliver)
        Deliverer.should_receive(:deadline_notification).with(@dn).and_return(mailer)
        @dn.deliver
      end
    end
    describe 'sendable?' do
      before(:each) do
        @dn = DeadlineNotification.new
        @dn.stub(:has_email? => true,
          :due_for_judgement? => true,
          :enabled? => true,
          :withdrawn? => false)
      end
      it 'should be true when has email, is due and is enabled' do
        @dn.should be_sendable
      end
      it 'should be false when has no email, is due and is enabled' do
        @dn.stub(:has_email? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when has email, is not due and is enabled' do
        @dn.stub(:due_for_judgement? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when has no email, is due and is not enabled' do
        @dn.stub(:has_email? => false, :enabled? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when has email, is not due and is not enabled' do
        @dn.stub(:due_for_judgement? => false, :enabled? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when has no email, is not due and is enabled' do
        @dn.stub(:has_email? => false, :due_for_judgement? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when has no email, not due, and disabled' do
        @dn.stub(:has_email? => false, :due_for_judgement? => false, :enabled? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when withdrawn' do
        @dn.stub(:withdrawn? => true)
        @dn.should_not be_sendable
      end
    end
  end
end
