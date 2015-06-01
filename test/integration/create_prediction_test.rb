require 'test_helper'

class CreatePredictionTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(valid_user_params)
    @user.reset_api_token!
  end

  test 'create valid prediction' do
    post '/api/predictions' + valid_query_string(@user.api_token), valid_prediction_params
    assert_equal 200, response.status
    assert_equal Mime::JSON, response.content_type
  end

  test 'refuse to create invalid prediction' do
    post '/api/predictions' + valid_query_string(@user.api_token), invalid_prediction_params
    assert_equal 422, response.status
    assert_equal Mime::JSON, response.content_type
  end

  test 'refuse to create prediction with invalid credentials' do
    post '/api/predictions', valid_prediction_params
    assert_equal 401, response.status
    refute_empty response.body
  end
end
