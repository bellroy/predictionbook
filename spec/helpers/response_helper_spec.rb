require 'spec_helper'

describe ResponseHelper do
  include ResponseHelper

  describe 'comment for' do
    before(:each) do
      @response = Response.new
    end

    it 'should ask the response if it has a comment' do
      @response.should_receive(:comment?).and_return(false)

      comment_for(@response)
    end

    it 'should not render anything if response does not have comment' do
      @response.stub(:comment?).and_return(false)

      comment_for(@response).should == nil
    end

    describe 'when has comment' do
      before(:each) do
        @comment = double('comment', :to_html => '', :starts_with? => false)
        @response.stub(:comment?).and_return(true)
        @response.stub(:comment).and_return(@comment)
        stub(:markup).and_return("comment")
      end
      it 'should get the responses comment' do
        @response.should_receive(:comment).at_least(:once).and_return(@comment)

        comment_for(@response)
      end
      describe 'action comment' do
        it 'should ask if it is one' do
          @response.should_receive(:action_comment?).and_return(false)

          comment_for(@response)
        end
        it 'should return comment without \me' do
          @response.stub(:action_comment?).and_return(true)
          @response.stub(:action_comment).and_return('shakes head')

          comment_for(@response).should have_selector('span[class="action-comment"]', :text=> 'shakes head')
        end
      end
      describe 'into html' do
        it 'should parse comment with the markup helper' do
          should_receive(:markup).with(@comment)

          comment_for(@response)
        end
        it 'should include the output from markup helper in the returned value' do
          stub(:markup).and_return('parsed markup')

          comment_for(@response).should =~ %r{parsed markup}
        end
      end
    end
  end
end
