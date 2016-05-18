require 'spec_helper'

describe FeedbackController do
  describe 'date' do
    it 'should parse the date with Chronic.parse' do
      expect(Chronic).to receive(:parse).with('a date string', anything)
      get :show, date: 'a date string'
    end

    describe 'successful parsing' do
      it 'renders text with the parsed date' do
        get :show, date: 'in 2 hours'
        expect(response.body).to match(/in about 2 hours/)
      end
    end

    describe 'failed parsing' do
      it 'returns a error 400' do
        allow(Chronic).to receive(:parse).and_return(nil)
        get :show, date: 'fumanchoo'
        expect(response.response_code).to eq 400
      end
    end
  end
end
