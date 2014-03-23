class CredenceController < ApplicationController
  def go
    @title = "Credence game"
    @game = CredenceGame.new
    @game.save
    current_user.credence_game = @game
    @question = @game.current_question

    @gave_answer = false
  end

  def answer
    @title = "Credence game"
    @game = current_user.credence_game

    question = @game.current_question
    given_answer = params.has_key?('submit-0') ? 0 : 1
    submit_name = "submit-#{given_answer}"
    credence = params[submit_name].to_i

    @correct = (given_answer == 0) && question.answer0_correct
    @score = question.score_answer(given_answer, credence)
    @game.score += @score

    @game.new_question
    @game.save
    @question = @game.current_question

    @gave_answer = true
    render "go"
  end
end
