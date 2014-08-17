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
    gen = create_valid_credence_question_generator
    [1, 1, 1, 1, 2].each do |rank|
      create_valid_credence_answer(credence_question_generator: gen, rank: rank)
    end

    100.times do
      q = gen.create_random_question
      q.answer0.rank.should_not == q.answer1.rank
    end
  end

  it 'should uniformly distribute questions in aswer-space' do
    pending "work out a good test to use"

    # gen.create_random_question is sufficiently slow that we don't want to do
    # it loads of times. But if we don't do it enough, our test will be prone to
    # failing randomly.
    #   Is it possible to only have this test run if we request it explicitly?

    gen = create_valid_credence_question_generator
    [1, 1, 2].each do |rank|
      create_valid_credence_answer(credence_question_generator: gen, rank: rank)
    end

    counts = Hash.new(0)
    400.times do
      q = gen.create_random_question
      key = [q.answer0.id, q.answer1.id]
      counts[key] += 1
    end

    # What tests do we apply to counts?
  end
end
