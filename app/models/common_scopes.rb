module CommonScopes
  def self.included(base)
    base.scope :limit, lambda { |*args| {:limit => args.first || 3} }
    base.scope :sort, lambda { |*args| {:order => "#{args.first || :created_at}"} }
    base.scope :rsort, lambda { |*args| {:order => "#{args.first || :created_at} DESC"} }
  end
end
