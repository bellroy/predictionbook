require 'spec_helper'

describe CredenceGame do
  include ModelFactory

  it 'should calculate score correctly' do
    g = valid_credence_game(num_answered: 3, score: 21)
    expect(g.average_score).to eq 7
  end

  it 'should give 0 score with no answered questions' do
    g = valid_credence_game(num_answered: 0, score: 0)
    expect(g.average_score).to eq 0
  end

  it 'should find answered questions' do
    g = create_valid_credence_game
    q1 = valid_answered_credence_question(credence_game: g)
    g.credence_questions = [g.current_question, q1]
    expect(g.answered_questions.length).to eq 1
  end
end
