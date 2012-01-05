class StatisticsSweeper < ActionController::Caching::Sweeper
  observe Judgement
  
  include CacheKeys
  
  def after_create(judgement)
    judgement.prediction.wagers.collect(&:user).each do |user|
      expire_fragment(user_statistics_cache_key(user))
    end
    
    expire_fragment(global_statistics_cache_key)
  end
end
