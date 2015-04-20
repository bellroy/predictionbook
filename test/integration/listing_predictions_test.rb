require 'test_helper'

class ListingPredictionsTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.create!(valid_user_params)
  end

  test 'valid username and password' do
    get "/api/predictions" + valid_query_string
    assert_equal 200, response.status
  end

  test 'missing credentials' do
    get '/api/predictions'
    assert_equal 401, response.status
  end

end
