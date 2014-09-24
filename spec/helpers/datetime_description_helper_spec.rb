require 'spec_helper'

describe DatetimeDescriptionHelper do
  include DatetimeDescriptionHelper

  describe 'time in words from now with context' do
    before(:each) do
      stub(:time_ago_in_words).and_return('time')
    end
    it 'should put "in" on the start when the time is in the future' do
      time = 2.months.from_now
      time_in_words_with_context(time).should == 'in time'
    end

    it 'should put "ago" on the end when the time is in the past' do
      time = 2.months.ago
      time_in_words_with_context(time).should == 'time ago'
    end

    it 'should use distance_of_time_in_words to englishificate the datetime' do
      should_receive(:time_ago_in_words).and_return('time')
      time_in_words_with_context(Time.now)
    end
  end

  describe 'regression test' do
    it 'should not crash on 100 years from now' do
      expect { time_in_words_with_context(100.years.from_now) }.not_to raise_error
    end
    it 'should not crash on 30 years from now' do
      expect { time_in_words_with_context(30.years.from_now) }.not_to raise_error
    end
  end

end
