require 'spec_helper'

describe CredenceQuestion do
  it 'should know right from wrong' do
    gen = CredenceQuestionGenerator.new(enabled: true, text: "a or b")
    a0 = CredenceAnswer.new(text: "a", value: "A")
    a1 = CredenceAnswer.new(text: "b", value: "B")
    q = CredenceQuestion.new(credence_question_generator: gen,
                             answer0: a0, answer1: a1,
                             correct_index: 1)
    q.answer_correct?(1).should == true
    q.answer_correct?(0).should == false
  end

  it 'should create random questions' do
    pending "Can I test this without a db?"
  end
end
