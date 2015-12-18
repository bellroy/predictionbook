class LeaderboardController < ApplicationController
  def leaderboard
    @title = "Leaderboard"
    @users = User.limit(100).sort_by {|user| user.statistics.score}.reverse
    @users.select! {|user| user.eligible_for_leaderboard?}
  end
end
