class Group < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :email_domains, format: {
    with: /\A(([a-z]+[a-z\.]+[\.]+[a-z]+),)*([a-z]+[a-z\.]+[\.]+[a-z]+)\z/, allow_nil: true
  }
end
