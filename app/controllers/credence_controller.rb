class CredenceController < ApplicationController
  def go
    @title = "Credence game"
    @question = CredenceQuestion.new

    session[:correct_index] = @question.correct_index
  end

  def answer
    @title = "Credence game"
    @question = CredenceQuestion.new

    given_answer = params.has_key?('submit-0') ? 0 : 1
    @correct = given_answer == session[:correct_index]
  end
end
