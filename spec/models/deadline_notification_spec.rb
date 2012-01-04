require File.dirname(__FILE__) + '/../spec_helper'

describe DeadlineNotification do
  describe 'class method' do
    describe 'named routes' do
      # have to hit the DB, named_routes rely on SQL
      describe 'unsent' do
        it 'should find all unsent' do
          unsent = DeadlineNotification.new(:sent => false)
          unsent.save(false)
          DeadlineNotification.new(:sent => true).save(false)
          
          DeadlineNotification.unsent.should == [unsent]
        end
      end
      describe 'sendable' do
        it 'should filter to having email and judgement due' do
          dns = mock('dns').as_null_object
          dns.should_recieve(:sendable?)
          DeadlineNotification.should_receive(:unsent).and_return(dns)
      
          DeadlineNotification.sendable
        end
      end
    end
    describe 'notify overdue unsent' do
      it 'should send notification emails for all unsent and overdue' do
        dn = DeadlineNotification.new
        dn.should_receive(:deliver!)
        DeadlineNotification.should_receive(:sendable).and_return([dn])
      
        DeadlineNotification.send_all!
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
        Deliverer.should_receive(:deliver_deadline_notification).with(@dn)
        @dn.deliver
      end
    end
    describe 'sendable?' do
      before(:each) do
        @dn = DeadlineNotification.new
        @dn.stub!(:has_email? => true,
          :due_for_judgement? => true,
          :enabled? => true,
          :withdrawn? => false)
      end
      it 'should be true when has email, is due and is enabled' do
        @dn.should be_sendable
      end
      it 'should be false when has no email, is due and is enabled' do
        @dn.stub!(:has_email? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when has email, is not due and is enabled' do
        @dn.stub!(:due_for_judgement? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when has no email, is due and is not enabled' do
        @dn.stub!(:has_email? => false, :enabled? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when has email, is not due and is not enabled' do
        @dn.stub!(:due_for_judgement? => false, :enabled? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when has no email, is not due and is enabled' do
        @dn.stub!(:has_email? => false, :due_for_judgement? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when has no email, not due, and disabled' do
        @dn.stub!(:has_email? => false, :due_for_judgement? => false, :enabled? => false)
        @dn.should_not be_sendable
      end
      it 'should be false when withdrawn' do
        @dn.stub!(:withdrawn? => true)
        @dn.should_not be_sendable
      end
    end
  end
end