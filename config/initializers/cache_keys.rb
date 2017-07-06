module CacheKeys
  def user_statistics_cache_key(user)
    "statistics_partial-#{user.to_param}"
  end

  def user_calibration_scores_cache_key(user)
    "calibration_scores_partial-#{user.to_param}"
  end

  def group_statistics_cache_key(group)
    "group_statistics_partial-#{group.to_param}"
  end

  def group_calibration_scores_cache_key(group)
    "group_calibration_scores_partial-#{group.to_param}"
  end

  def group_leaderboard_cache_key(group)
    "group_leaderboard_partial-#{group.to_param}"
  end

  def global_statistics_cache_key
      "statistics_partial"
  end
end
