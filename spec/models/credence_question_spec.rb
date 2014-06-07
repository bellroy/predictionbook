require 'spec_helper'

describe CredenceQuestion do
  it 'should know right from wrong' do
    gen = CredenceQuestionGenerator.new(enabled: true, text: "a or b")
    a0 = CredenceAnswer.new(text: "a", value: "A")
    a1 = CredenceAnswer.new(text: "b", value: "B")
    q = CredenceQuestion.new(credence_question_generator: gen,
                             answer0: a0, answer1: a1,
                             correct_index: 1)
    q.answer_correct?(1).should == true
    q.answer_correct?(0).should == false
  end

  it 'should give correct scores to specific credences' do
    gen = CredenceQuestionGenerator.new(enabled: true, text: "a or b")
    a0 = CredenceAnswer.new(text: "a", value: "A")
    a1 = CredenceAnswer.new(text: "b", value: "B")
    q = CredenceQuestion.new(credence_question_generator: gen,
                             answer0: a0, answer1: a1,
                             correct_index: 1)

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
