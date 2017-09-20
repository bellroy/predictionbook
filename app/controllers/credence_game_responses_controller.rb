# frozen_string_literal: true

class CredenceGameResponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_response
  before_action :check_response_for_current_user
  before_action :set_game

  def update
    correct, score = @response.score_answer
    if @game.current_response_id == @response.id
      if @response.save
        @game.add_score(score)
      else
        flash[:error] = @response.errors.full_messages.join(', ')
      end
    end
    flash.merge!(correct: correct, score: score, message: @response.answer_message)
    redirect_to credence_game_path('try')
  end

  private

  def set_response
    @response = CredenceGameResponse.find(params[:id])
    @response.assign_attributes(response_params)
  end

  def check_response_for_current_user
    head :forbidden if @response.credence_game.user_id != current_user.id
  end

  def response_params
    params
      .require(:response)
      .permit(:answer_credence, :given_answer)
      .merge(answered_at: Time.zone.now)
  end

  def set_game
    @game = current_user.credence_game
  end
end
