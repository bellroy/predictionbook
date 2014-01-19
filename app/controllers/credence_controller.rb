class CredenceController < ApplicationController
  def go
    @title = "Credence game"
    @question = CredenceQuestion.new
    session[:question] = @question
  end

  def answer
    @title = "Credence game"

    question = session[:question]
    given_answer = params.has_key?('submit-0') ? 0 : 1
    submit_name = "submit-#{given_answer}"
    credence = params[submit_name].to_i

    @correct = given_answer == question.correct_index
    @score = question.score_answer(given_answer, credence)

    @question = CredenceQuestion.new
    session[:question] = @question
  end
end
