require 'spec_helper'

describe CredenceGameResponse do
  it 'should know right from wrong' do
    q1 = create_valid_credence_game_response(correct_index: 0)
    expect(q1.answer_correct?(1)).to eq false
    expect(q1.answer_correct?(0)).to eq true

    q2 = create_valid_credence_game_response(correct_index: 1)
    expect(q2.answer_correct?(1)).to eq true
    expect(q2.answer_correct?(0)).to eq false
  end

  it 'should give correct scores to specific credences' do
    q = create_valid_credence_game_response(correct_index: 1)

    right_scores = { 50 => 0, 51 => 3, 60 => 26, 70 => 49,
                     80 => 68, 90 => 85, 99 => 99 }
    wrong_scores = { 50 => 0, 51 => -3, 60 => -32, 70 => -74,
                     80 => -132, 90 => -232, 99 => -564 }

    right_scores.each do |cred, score|
      expect(q.score_answer(1, cred)).to eq [true, score]
    end

    wrong_scores.each do |cred, score|
      expect(q.score_answer(0, cred)).to eq [false, score]
    end
  end

  it 'should reject certainty in predictions' do
    q = create_valid_credence_game_response
    expect { q.score_answer(0, 0) }.to raise_error ArgumentError
    expect { q.score_answer(0, 100) }.to raise_error ArgumentError
    expect { q.score_answer(1, 0) }.to raise_error ArgumentError
    expect { q.score_answer(1, 100) }.to raise_error ArgumentError
  end

  it 'should create random questions' do
    gen = create_valid_credence_question
    a1 = create_valid_credence_answer(credence_question: gen, rank: 0)
    a2 = create_valid_credence_answer(credence_question: gen, rank: 1)
    q = CredenceGameResponse.pick_random
  end

  it 'should not randomly create questions that have been disabled' do
    def make_generator (e=false)
      gen = create_valid_credence_question(enabled: e)
      a1 = create_valid_credence_answer(credence_question: gen, rank: 0)
      a2 = create_valid_credence_answer(credence_question: gen, rank: 1)
      gen
    end

    gen = make_generator(true)
    4.times do
      make_generator
    end

    10.times do
      q = CredenceGameResponse.pick_random
      expect(q.credence_question).to eq gen
    end
  end

  it 'should consider generators according to their weight' do
    pending "work out a good test to use"
    raise "not yet implemented"
  end
end
