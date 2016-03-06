require 'spec_helper'

describe CredenceGameResponse do
  it 'should know right from wrong' do
    question_1 = create_valid_credence_game_response(correct_index: 0)
    expect(question_1.answer_correct?(1)).to eq false
    expect(question_1.answer_correct?(0)).to eq true

    question_2 = create_valid_credence_game_response(correct_index: 1)
    expect(question_2.answer_correct?(1)).to eq true
    expect(question_2.answer_correct?(0)).to eq false
  end

  it 'should give correct scores to specific credences' do
    response = create_valid_credence_game_response(correct_index: 1)

    right_scores = { 50 => 0, 51 => 3, 60 => 26, 70 => 49,
                     80 => 68, 90 => 85, 99 => 99 }
    wrong_scores = { 50 => 0, 51 => -3, 60 => -32, 70 => -74,
                     80 => -132, 90 => -232, 99 => -564 }

    right_scores.each do |cred, score|
      expect(response.score_answer(1, cred)).to eq [true, score]
    end

    wrong_scores.each do |cred, score|
      expect(response.score_answer(0, cred)).to eq [false, score]
    end
  end

  it 'should reject certainty in predictions' do
    response = create_valid_credence_game_response
    expect { response.score_answer(0, 0) }.to raise_error ArgumentError
    expect { response.score_answer(0, 100) }.to raise_error ArgumentError
    expect { response.score_answer(1, 0) }.to raise_error ArgumentError
    expect { response.score_answer(1, 100) }.to raise_error ArgumentError
  end

  it 'should create random questions' do
    question = create_valid_credence_question
    create_valid_credence_answer(credence_question: question, rank: 0)
    create_valid_credence_answer(credence_question: question, rank: 1)
    response = CredenceGameResponse.pick_random
    expect(response.class).to eq CredenceGameResponse
  end

  it 'should not randomly create questions that have been disabled' do
    def make_question (enabled=false)
      question = create_valid_credence_question(enabled: enabled)
      create_valid_credence_answer(credence_question: question, rank: 0)
      create_valid_credence_answer(credence_question: question, rank: 1)
      question
    end

    question = make_question(true)
    4.times do
      make_question
    end

    10.times do
      response = CredenceGameResponse.pick_random
      expect(response.credence_question).to eq question
    end
  end

  it 'should consider generators according to their weight' do
    pending "work out a good test to use"
    raise "not yet implemented"
  end
end
