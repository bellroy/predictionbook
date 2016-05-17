require 'spec_helper'

describe CredenceGame do
  include ModelFactory

  it 'should calculate score correctly' do
    game = valid_credence_game(num_answered: 3, score: 21)
    expect(game.average_score).to eq 7
  end

  it 'should give 0 score with no answered questions' do
    game = valid_credence_game(num_answered: 0, score: 0)
    expect(game.average_score).to eq 0
  end

  it 'should find answered questions' do
    game = create_valid_credence_game
    question = valid_answered_credence_question
    game.credence_game_responses = [game.current_response, question]
    expect(game.answered_questions.length).to eq 1
  end

  it 'should find most recently answered questions' do
    game = create_valid_credence_game
    questions = (1..5).map do |n|
      valid_answered_credence_question(answered_at: 20150101 + n)
    end
    game.credence_game_responses = [game.current_response] + questions

    expect(game.most_recently_answered(2).length).to eq 2
    expect(game.most_recently_answered(3).length).to eq 3
    expect(game.most_recently_answered(10).length).to eq 5

    # The most recent ones are the ones at the end
    recent_3 = game.most_recently_answered(3)
    expect(recent_3).to eq [questions[4], questions[3], questions[2]]
  end
end
