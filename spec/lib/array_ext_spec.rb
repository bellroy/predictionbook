require 'spec_helper'

describe 'Array core extensions' do
  describe 'rsort!' do
    it 'should reverse order the elements by the field passed' do
      a = mock('1', :number => 100)
      b = mock('2', :number => 200)
      c = mock('3', :number => 300)
      ary = [a,b,c]
      ary.rsort(:number).should == [c,b,a]
    end
  end
  describe 'limit' do
    it 'get the first n elements' do
      [1,2,3,4,5].limit(2).should == [1,2]
    end
  end
end
