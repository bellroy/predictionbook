class UserLogin
  def initialize(login)
    self.login = login
  end

  def to_s
    login.gsub('[dot]', '.')
  end

  private

  attr_accessor :login
end
