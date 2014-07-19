require 'spec_helper'

describe CredenceQuestion do
  it 'should know right from wrong' do
    q1 = create_valid_credence_question(correct_index: 0)
    q1.answer_correct?(1).should == false
    q1.answer_correct?(0).should == true

    q2 = create_valid_credence_question(correct_index: 1)
    q2.answer_correct?(1).should == true
    q2.answer_correct?(0).should == false
  end

  it 'should give correct scores to specific credences' do
    q = create_valid_credence_question(correct_index: 1)

    right_scores = { 50 => 0, 51 => 3, 60 => 26, 70 => 49,
                     80 => 68, 90 => 85, 99 => 99 }
    wrong_scores = { 50 => 0, 51 => -3, 60 => -32, 70 => -74,
                     80 => -132, 90 => -232, 99 => -564 }

    right_scores.each do |cred, score|
      q.score_answer(1, cred).should == [true, score]
    end

    wrong_scores.each do |cred, score|
      q.score_answer(0, cred).should == [false, score]
    end
  end

  it 'should create random questions' do
    pending "Can I test this without a db?"
  end
end
