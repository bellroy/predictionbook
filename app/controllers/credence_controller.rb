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
    game = current_user.credence_game
    question = game.current_question

    given_answer = params.has_key?('submit-0') ? 0 : 1
    submit_name = "submit-#{given_answer}"
    credence = params[submit_name].to_i

    correct, score = question.score_answer(given_answer, credence)
    game.score += score

    game.new_question
    game.save

    flash[:correct] = correct
    flash[:score] = score
    flash[:message] = question.answer_message(given_answer)

    redirect_to action: 'show'
  end

  def destroy
    current_user.credence_game = nil
    redirect_to action: 'show'
  end
end
