class CredenceController < ApplicationController
  def go
    @title = "Credence game"
    @game = CredenceGame.new
    session[:game] = @game
    @question = @game.current_question
  end

  def answer
    @title = "Credence game"
    @game = session[:game]

    question = @game.current_question
    given_answer = params.has_key?('submit-0') ? 0 : 1
    submit_name = "submit-#{given_answer}"
    credence = params[submit_name].to_i

    @correct = given_answer == question.correct_index
    @score = question.score_answer(given_answer, credence)
    @game.score += @score

    @game.new_question
    @question = @game.current_question
  end
end
