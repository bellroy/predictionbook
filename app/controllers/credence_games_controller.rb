class CredenceGamesController < ApplicationController
  before_action :authenticate_user!

  def show
    @title = 'Credence game'

    if CredenceQuestion.exists?
      @game = CredenceGame.find_or_create_by(user_id: current_user.id)
      @response = @game.current_response
      @show_graph = @game.num_answered > 10 && @game.num_answered % 10 == 0
    end
  end

  def destroy
    CredenceGame.find(params[:id]).destroy
    redirect_to credence_game_path('try')
  end
end
