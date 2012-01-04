module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    fixture_users
    @request.session[:user_id] = user ? User.find_by_login(user.to_s).id : nil
  end

  def authorize_as(user)
    fixture_users
    login = user ? User.find_by_login(user.to_s).login : nil
    @request.env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials(login, 'monkey')
  end
  
  def fixture_users
    User.delete_all(:login => 'quentin')
    User.create!(
      :login => 'quentin',
      :email => 'quentin@example.com',
      :password => 'monkey',
      :password_confirmation => 'monkey'
    )
  end
  
  # rspec
  def mock_user
    user = mock_model(User, :id => 1,
      :login  => 'user_name',
      :name   => 'U. Surname',
      :to_xml => "User-in-XML", :to_json => "User-in-JSON", 
      :errors => [])
    user
  end  
end
