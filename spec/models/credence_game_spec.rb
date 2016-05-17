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
    question = valid_answered_credence_question(credence_game: game)
    game.credence_game_responses = [game.current_response, question]
    expect(game.answered_questions.length).to eq 1
  end
end
