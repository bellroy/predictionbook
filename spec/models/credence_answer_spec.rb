require 'spec_helper'

describe CredenceAnswer do
  it 'should include the text and value when displayed' do
    a = create_valid_credence_answer(text: 'xyzzy', value: 'FlibbertY')
    a.format.include?(a.text).should == true
    a.format.include?(a.value).should == true
  end
end
