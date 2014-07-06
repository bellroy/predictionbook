require 'spec_helper'

describe CredenceGame do
  include ModelFactory

  it 'should calculate score correctly' do
    g = valid_credence_game(num_answered: 3, score: 21)
    g.average_score.should == 7
  end

  it 'should give 0 score with no answered questions' do
    g = valid_credence_game(num_answered: 0, score: 0)
    g.average_score.should == 0
  end

  it 'should find answered questions' do
    g = create_valid_credence_game
    q1 = valid_answered_credence_question(credence_game: g)
    g.credence_questions = [g.current_question, q1]
    g.answered_questions.length.should == 1
  end
end
