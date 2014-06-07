require 'spec_helper'

describe CredenceAnswer do
  it 'should include the text and value when displayed' do
    gen = CredenceQuestionGenerator.new
    a = CredenceAnswer.new(text: 'xyzzy', value: 'FlibbertY',
                           credence_question_generator: gen)
    a.format.include?(a.text).should == true
    a.format.include?(a.value).should == true
  end
end
