require 'spec_helper'

describe 'Array core extensions' do
  describe 'rsort!' do
    it 'should reverse order the elements by the field passed' do
      a = double('1', :number => 100)
      b = double('2', :number => 200)
      c = double('3', :number => 300)
      ary = [a,b,c]
      ary.rsort(:number).should == [c,b,a]
    end
  end
end
