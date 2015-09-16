require 'spec_helper'

describe CredenceQuestion do
  it 'should be able to create random questions' do
    gen = create_valid_credence_question
    as = (0..9).map do |rank|
      create_valid_credence_answer(credence_question: gen, rank: rank)
    end

    q = gen.create_random_question
    expect(q.class).to eq CredenceGameResponse
  end

  it 'should not create a question where both answers have the same rank' do
    gen = create_valid_credence_question
    [1, 1, 1, 1, 2].each do |rank|
      create_valid_credence_answer(credence_question: gen, rank: rank)
    end

    100.times do
      q = gen.create_random_question
      expect(q.first_answer.rank).to_not eq q.second_answer.rank
    end
  end

  it 'should uniformly distribute questions in aswer-space' do
    pending "work out a good test to use"
    raise "not yet implemented"

    # gen.create_random_question is sufficiently slow that we don't want to do
    # it loads of times. But if we don't do it enough, our test will be prone to
    # failing randomly.
    #   Is it possible to only have this test run if we request it explicitly?

    gen = create_valid_credence_question
    [1, 1, 2].each do |rank|
      create_valid_credence_answer(credence_question: gen, rank: rank)
    end

    counts = Hash.new(0)
    400.times do
      q = gen.create_random_question
      key = [q.first_answer.id, q.second_answer.id]
      counts[key] += 1
    end

    # What tests do we apply to counts?
  end
end
