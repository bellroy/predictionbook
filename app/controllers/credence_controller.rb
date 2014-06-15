class CredenceController < ApplicationController
  def show
    @title = "Credence game"

    @game = CredenceGame.find_or_create_by_user_id current_user.id
    @question = @game.current_question
    @gave_answer = false
  end

  def update
    game = current_user.credence_game
    question = game.current_question

    given_answer = params[:answer_index].to_i
    credence = params[:credence].to_i

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
