require 'spec_helper'

describe Statistics do  
  include WagersFactory
  describe 'iteration' do
    it 'should iterate over Statistic::Inverval objects' do
      # This now needs to use WagersFactroy in order to avoid having the outcome prediction be undefined, which would
      # mess up the scoring code that rightly expects that each prediction is either true, false, or unknown.
      stats = Statistics.new(build_wagers [[50, nil]]) 
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
  describe 'score' do
    it 'should be 1 if there are no predictions' do
      Statistics.new([]).score.should == 1
    end
    it 'should be 1 if there is a single judged prediction at 50%' do
      Statistics.new(build_wagers [[50,true]]).score.should == 1
    end
    it 'should be 1 if all judged predictions are 50%' do
      Statistics.new(build_wagers [[50,true],[50,false],[50,true],[100,nil],[20,nil]]).score.should == 1
    end
    it 'should be 3.11 if there is a single judged prediction at 80% confidence that was correct.' do
      Statistics.new(build_wagers [[80,true]]).score.should == 3.11
    end
    it 'should be 3.11 if there is a single judged prediction at 20% confidence that was incorrect.' do
      Statistics.new(build_wagers [[20,false]]).score.should == 3.11
    end
    it 'should still be 3.11 if you add on an unknown prediction.' do
      Statistics.new(build_wagers [[20,false],[40,nil]]).score.should == 3.11
    end
    it 'should be 0.3 if there is a single judged prediction at 90% confidence that was incorrect.' do
      Statistics.new(build_wagers [[90,false]]).score.should == 0.3
    end
    it 'should be 0.13 if there is a single judged prediction at 0% (that is, 0.5%) confidence that was correct.' do
      Statistics.new(build_wagers [[0,true]]).score.should == 0.13
    end
    it 'should be 0.69 if there are 3 judged predictions at 90%, 70%, 30% confidence that were incorrect, correct, and incorrect respectively.' do
      Statistics.new(build_wagers [[90,false],[70,true],[30, false]]).score.should == 0.69
    end
    it "should be 1.58 when given the data from Gwern's Nootropics essay." do
      wagers = build_wagers [[95, true], [30, false], [85, true], [75, true], [50, false], [25, false], [60, false], 
             [70, true], [65, true], [60, true], [30, false], [50, true], [90, true], [40, true]]
      Statistics.new(wagers).score.should == 1.58
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
        response.stub!(:correct?).and_return(outcomes.first)
        response.stub!(:unknown?).and_return(outcomes.first.nil?)
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
