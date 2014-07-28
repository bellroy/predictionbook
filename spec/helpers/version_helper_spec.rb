require 'spec_helper'

describe VersionHelper do
  describe 'changes' do
    it 'should compare to versions and return the change details of only the fields that have changed' do
      v1 = double('version 1', :attributes => { 'deadline' => 'a', 'withdrawn' => 'b'})
      v2 = double('version 2', :previous => v1, :attributes => { 'deadline' => 'a', 'withdrawn' => 'd' })
      # rspec stubs don't let you do this, and stub is breaking method existance as of rspec 1.1.8
      def helper.changed_detail(*args); args.first; end
      helper.changes(v2).should include('withdrawn')
      helper.changes(v2).should_not include('deadline')
    end
  end

  describe 'changed_detail' do
    it 'should describe a changed description' do
      helper.stub(:show_title).with('old desc').and_return('title')
      helper.changed_detail(:description, 'new desc', 'old desc').should =~ /changed their prediction from.*title.*/
    end

    it 'should describe a changed deadline' do
      old_time = 40.minutes.ago
      helper.stub(:show_time).with(old_time).and_return('old time')
      helper.changed_detail(:deadline, 10.minutes.from_now, old_time).should =~ /changed the deadline from.+old time.*/
    end

    it 'should say the predition was withdrawn' do
      helper.changed_detail(:withdrawn, true, false).should == 'withdrew the prediction'
    end

    it 'should say the prediction was made private' do
      helper.changed_detail(:private, true, false).should == 'made the prediction private'
    end

    it 'should say the prediction was made public' do
      helper.changed_detail(:private, false, true).should == 'made the prediction public'
    end
  end
end
