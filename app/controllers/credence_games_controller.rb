class CredenceGamesController < ApplicationController
  before_filter :login_required

  def index
    @title = "Credence game"

    if CredenceQuestion.exists?
      @game = CredenceGame.find_or_create_by_user_id current_user.id
      if @game.present?
        @question = @game.current_response
        @show_graph = @game.num_answered > 10 && @game.num_answered % 10 == 0
      end
    end
  end

  def update
    game = current_user.credence_game
    question = game.current_response

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
    else
      # If the ids don't match, assume that the user submitted the form multiple
      # times. Since we use CookieStore, the flash doesn't get set properly, so
      # we can't just call flash.keep. We have to reconstruct it.
      question = CredenceGameResponse.find(params[:question_id].to_i)
      given_answer = question.given_answer
      credence = question.answer_credence
      correct, score = question.score_answer(given_answer, credence)
    end

    flash[:correct] = correct
    flash[:score] = score
    flash[:message] = question.answer_message(given_answer, score)

    redirect_to credence_games_path
  end

  def destroy
    current_user.credence_game = nil
    redirect_to credence_games_path
  end
end
