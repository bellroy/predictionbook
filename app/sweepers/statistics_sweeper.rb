class StatisticsSweeper < ActionController::Caching::Sweeper
  observe Judgement

  include CacheKeys

  def after_create(judgement)
    associated_users = judgement.prediction.wagers.collect(&:user).uniq

    associated_users.each do |user|
      Rails.cache.clear(user_statistics_cache_key(user))
      user.reset_score
    end

    Rails.cache.clear(global_statistics_cache_key)
  end
end
