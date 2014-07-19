require 'spec_helper'

describe CredenceQuestionGenerator do
  it 'should be able to create random questions' do
    gen = create_valid_credence_question_generator
    as = (0..9).map do |rank|
      create_valid_credence_answer(credence_question_generator: gen, rank: rank)
    end

    q = gen.create_random_question
    q.class.should == CredenceQuestion
  end

  it 'should not create a question where both answers have the same rank' do
    pending "to be done"
  end
end
