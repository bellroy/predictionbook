class CredenceController < ApplicationController
  before_filter :login_required

  def show
    @title = "Credence game"

    @game = CredenceGame.find_or_create_by_user_id current_user.id
    @question = @game.current_question

    @show_graph = @game.num_answered > 10 && @game.num_answered % 10 == 0
  end

  def update
    game = current_user.credence_game
    question = game.current_question

    if params[:question_id].to_i == question.id
      given_answer = params[:answer_index].to_i
      credence = params[:credence].to_i
      correct, score = question.score_answer(given_answer, credence)

      question.given_answer = given_answer
      question.answer_credence = credence
      question.answered_at = Time.now
      question.save

      game.score += score
      game.num_answered += 1
      game.new_question
      game.save

      flash[:correct] = correct
      flash[:score] = score
      flash[:message] = question.answer_message(given_answer, score)
    else
      # If the ids don't match, assume that the user submitted the form multiple
      # times. Since we use CookieStore, the flash doesn't get set properly, so
      # we can't just call flash.keep. We have to reconstruct it.
      question = CredenceQuestion.find(params[:question_id].to_i)
      given_answer = question.given_answer
      credence = question.answer_credence
      correct, score = question.score_answer(given_answer, credence)

      flash[:correct] = correct
      flash[:score] = score
      flash[:message] = question.answer_message(given_answer, score)
    end

    redirect_to action: 'show'
  end

  def destroy
    current_user.credence_game = nil
    redirect_to action: 'show'
  end
end
