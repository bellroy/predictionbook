class CredenceController < ApplicationController
  def show
    @title = "Credence game"

    if current_user.credence_game.nil?
      @game = CredenceGame.new
      @game.save
      current_user.credence_game = @game
    else
      @game = current_user.credence_game
    end

    @question = @game.current_question
    @gave_answer = false
  end

  def update
    @title = "Credence game"
    @game = current_user.credence_game

    question = @game.current_question
    given_answer = params.has_key?('submit-0') ? 0 : 1
    submit_name = "submit-#{given_answer}"
    credence = params[submit_name].to_i

    @correct = given_answer == question.correct_index
    @score = question.score_answer(given_answer, credence)
    @game.score += @score

    @game.new_question
    @game.save
    @question = @game.current_question

    @gave_answer = true
    render "show"
  end
end
