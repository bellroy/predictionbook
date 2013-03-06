module CommonScopes
  def self.included(base)
    base.scope :sort, lambda { |*args| {:order => "#{args.first || :created_at}"} }
    base.scope :rsort, lambda { |*args| {:order => "#{args.first || :created_at} DESC"} }
  end
end
