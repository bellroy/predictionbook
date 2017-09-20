# frozen_string_literal: true

class CredenceGamesController < ApplicationController
  before_action :authenticate_user!

  def show
    @title = 'Credence game'

    return unless CredenceQuestion.exists?

    @game = CredenceGame.find_or_create_by(user_id: current_user.id)
    @response = @game.current_response
    num_answered = @game.num_answered
    @show_graph = num_answered > 10 && (num_answered % 10).zero?
  end

  def destroy
    CredenceGame.find(params[:id]).destroy
    redirect_to credence_game_path('try')
  end
end
