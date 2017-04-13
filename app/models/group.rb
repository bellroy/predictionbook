class Group < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  # Regex validates comma-delimited list of valid email domains with no spaces
  validates :email_domains, format: {
    with: /\A(([a-z]+[a-z\.]+[\.]+[a-z]+),)*([a-z]+[a-z\.]+[\.]+[a-z]+)\z/, allow_nil: true
  }

  def user_is_a_member?(user)
    domain = Mail::Address.new(user.email).domain
    (email_domains || '').split(',').include?(domain)
  end
end
