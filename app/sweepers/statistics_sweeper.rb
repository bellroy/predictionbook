class StatisticsSweeper < ActionController::Caching::Sweeper
  observe Judgement

  include CacheKeys

  def after_create(judgement)
    judgement.prediction.wagers.collect(&:user).each do |user|
      Rails.cache.clear(user_statistics_cache_key(user))
    end

    Rails.cache.clear(global_statistics_cache_key)
  end
end
