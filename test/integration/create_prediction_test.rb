require 'test_helper'

class CreatePredictionTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.create!(valid_user_params)
  end

  test 'create valid prediction' do
    post "/api/predictions" + valid_query_string, valid_prediction_params
    assert_equal 200, response.status
  end

  test 'refuse to create invalid prediction' do
    post '/api/predictions' + valid_query_string, invalid_prediction_params
    assert_equal 422, response.status
  end

  test 'refuse to create prediction with invalid credentials' do
    post '/api/predictions', valid_prediction_params
    assert_equal 401, response.status
  end

end
