require 'spec_helper'

describe Statistics do
  describe 'iteration' do
    it 'should iterate over Statistic::Inverval objects' do
      stats = Statistics.new([Response.new(:confidence => 50)])
      stats.each do |stat|
        stat.should be_kind_of(Statistics::Interval)
      end
    end
  end
  describe 'prefetch joins' do
    it 'should happen if it is supported' do
      stats = []
      stats.should_receive(:prefetch_joins).and_return(stats)
      Statistics.new(stats)
    end
    it 'should not happen if not supported' do
      Statistics.new([])
    end
  end
end

describe Statistics::Interval do
  describe 'ranges' do
    before(:each) do
      wagers = []
      outcomes = [true, false, nil]
      (0..100).each do |c|
        response = Response.new(:confidence => c)
        response.stub(:correct?).and_return(outcomes.first)
        response.stub(:unknown?).and_return(outcomes.first.nil?)
        wagers << response
        # cycle outcomes
        outcomes.unshift(outcomes.pop)
      end
      @i50,@i60,@i70,@i80,@i90,@i100 = Statistics.new(wagers).map { |interval| interval }
    end

    describe 'heading' do
      it 'should be descriptive of the range' do
        @i50.heading.should == '50'
      end
      it 'should be == 100 for 100' do
        @i100.heading.should == '100'
      end
    end
    describe 'count' do
      #TODO: make these not depend on indecipherable setup code
      it 'should equal the number of wagers' do
        @i50.count.should == 13
        @i60.count.should == 13
        @i100.count.should == 1
      end
    end
    describe 'accuracy' do
      it 'should equal the percentage of correct wagers' do
        @i50.accuracy.should == (6.0/13*100).round
        @i60.accuracy.should == (7.0/13*100).round
        @i100.accuracy.should == 100
      end
    end
  end
end
