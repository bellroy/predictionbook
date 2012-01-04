require File.dirname(__FILE__) + '/../spec_helper'

describe Deliverer do
  it 'should set default host (we are not in a controller)' do
    Deliverer.default_url_options[:host].should == 'localhost:3000'
  end

  describe 'deadline notification' do  
    before(:each) do
      @dn = mock('deadline notification', :null_object => true, :to_param => '1')
    end
    
    def create_deadline_notification
      Deliverer.create_deadline_notification(@dn)
    end
    
    describe 'headers' do
      def header(value)
        # value.gsub so you can use underscored symbols as args for header keys
        str = create_deadline_notification.header[value.to_s.gsub(/_/,'-')].to_s
        
        # This a bit of hack around the ActionMailer returning empty stings
        # for these headers
        create_deadline_notification.header[value.to_s.gsub(/_/,'-')].instance_variable_get(:@body)
      end
      
      it 'should have a recipient of email and name pair' do
        @dn.should_receive(:email_with_name).at_least(1).and_return(%{"Joe Blogs" <joe@blogs.com>})

        header(:to).should == %{"Joe Blogs" <joe@blogs.com>}
      end
      
      it 'should have a reply to' do
        header(:reply_to).should == %{"PredictionBook" <no-reply@localhost:3000>}
      end
      
      it 'should have a sender' do
        header(:from).should == %{"PredictionBook" <no-reply@localhost:3000>}
      end
      
      it 'should have a content type' do
        header(:content_type).should == "multipart/alternative"
      end
      
      it 'should have a subject' do
        @dn.should_receive(:description).at_least(1).and_return("my description")
        body = create_deadline_notification.header['subject'].to_s
        TMail::Unquoter.unquote_and_convert_to(body,'utf8').should == "[PredictionBook] Judgement Day for ‘my description’"
      end
    end
    
    describe 'body' do
      def part_for(enc_type)
        create_deadline_notification.parts.find {|p| p.content_type == enc_type }
      end
      
      describe 'text/plain' do
        def part
          part_for('text/plain')
        end
        
        it 'should exist' do
          part.should_not be_nil
        end
        
        it 'should have a link to the prediction' do
          part.body.should =~ %r{http://[^/]+/predictions/1}
        end
        
        it 'should have a login token in the action link' do
          @dn.stub!(:uuid).and_return("login_token")
          part.body.should =~ %r{predictions/1\?token=login_token}
        end
      end
      
      describe 'text/html' do
        def part
          part_for('text/html')
        end
        
        it 'should exist' do
          part.should_not be_nil
        end
        
        it 'should have a link to the prediction with a login token in the action link' do
          # can't do this as separate assertions since the have_tag matcher doesn't let you
          # do regex matches against the ? param in the selector
          # assert select docs say it can so matcher must break it somehow
          @dn.stub!(:uuid).and_return("login_token")
          part.body.should =~ %r{<a href="http://[^/]+/predictions/1\?token=login_token">}
        end
      end
    end
  end
end