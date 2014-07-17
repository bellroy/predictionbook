require 'spec_helper'

describe FeedbackController do
  describe 'date' do
    it 'should parse the date with Chronic.parse' do
      Chronic.should_receive(:parse).with('a date string',anything)
      get :show, :date => 'a date string'
    end
    describe 'successful parsing' do
      it 'should render text with the parsed date' do
        get :show, :date => 'in 2 hours'
        response.body.should match(/in about 2 hours/)
      end
    end
    describe 'failed parsing' do
      it 'should return a error 400' do
        Chronic.stub(:parse).and_return(nil)
        get :show, :date => 'fumanchoo'
        response.response_code.should == 400
      end
    end
  end
end
