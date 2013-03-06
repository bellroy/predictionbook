module CacheKeys
  
  def user_statistics_cache_key(user)
    "statistics_partial-#{user.to_param}"
  end
    
  def global_statistics_cache_key
      "statistics_partial"
  end
        
end