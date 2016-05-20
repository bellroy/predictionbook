require 'spec_helper'

describe MarkupHelper do
  include MarkupHelper

  describe '#confidence_and_count' do
    it 'returns the number of wagers of a prediction' do
      prediction = double(Prediction, wager_count: 20).as_null_object
      expect(confidence_and_count(prediction)).to match(/20/)
    end

    it 'returns the mean confidence of a prediction' do
      prediction = double(Prediction, mean_confidence: '13').as_null_object
      expect(confidence_and_count(prediction)).to match(/13/)
    end
  end

  describe 'certainty_heading' do
    it 'should not add % to the end of the heading' do
      expect(certainty_heading('60')).to eq '60'
    end

    describe '100% easter egg' do
      before(:each) do
        @egg = certainty_heading('100')
      end
      it 'should add wiki almost surely article link' do
        link = 'http://en.wikipedia.org/wiki/Almost_surely'
        expect(@egg).to have_link('Almost surely', href: link)
      end
    end
  end

  describe 'css classes helper' do
    it 'should join args together with spaces' do
      expect(classes('one', 'two')).to eq 'one two'
    end

    it 'filters out nils' do
      expect(classes('test', nil, 'val')).to eq 'test val'
    end

    it 'should flatten lists in the argument list' do
      expect(classes('test', %w[two three])).to eq 'test two three'
    end
  end
end
