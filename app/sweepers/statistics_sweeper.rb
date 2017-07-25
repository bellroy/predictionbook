class StatisticsSweeper < ActionController::Caching::Sweeper
  observe Judgement

  include CacheKeys

  def after_create(judgement)
    associated_users = judgement.prediction.wagers.collect(&:user).uniq
    clear_user_caches(associated_users)
    clear_group_caches(associated_users)
    Rails.cache.clear(global_statistics_cache_key)
  end

  private

  def clear_user_caches(associated_users)
    cache = Rails.cache
    associated_users.each do |user|
      cache.clear(user_statistics_cache_key(user))
      cache.clear(user_calibration_scores_cache_key(user))
    end
  end

  def clear_group_caches(associated_users)
    cache = Rails.cache
    associated_groups =
      GroupMember.includes(:group).where(user_id: associated_users.map(&:id)).map(&:group).uniq
    associated_groups.each do |group|
      cache.clear(group_statistics_cache_key(group))
      cache.clear(group_calibration_scores_cache_key(group))
      cache.clear(group_leaderboard_cache_key(group))
    end
  end
end
