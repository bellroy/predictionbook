require 'spec_helper'

describe "ArrayMatchers" do
  it 'should check the ordered containment matcher works' do
    [10,20,5,11].should contain_in_order([20,5])
  end

  it 'should check the matcher catches a proper fail' do
    lambda { [5,3,2,1].should contain_in_order([1,2]) }.should raise_error
  end
end
