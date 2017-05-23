class StatisticsSweeper < ActionController::Caching::Sweeper
  observe Judgement

  include CacheKeys

  def after_create(judgement)
    associated_users = judgement.prediction.wagers.collect(&:user).uniq

    associated_users.each do |user|
      Rails.cache.clear(user_statistics_cache_key(user))
      Rails.cache.clear(user_calibration_scores_cache_key(user))
    end

    Rails.cache.clear(global_statistics_cache_key)
  end
end
