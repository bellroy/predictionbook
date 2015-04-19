class ListingPredictionsTest < ActionDispatch::IntegrationTest

  setup { @user = User.create!(login: "MoritzSchlick", password: "verified") }

  test 'valid username and password' do
    get 'api/predictions', {}, { 'Authorization' => 'Basic TW9yaXR6U2NobGljazp2ZXJpZmllZA==' }
    assert_equal 200, response.status
  end

  test 'missing credentials' do
    get 'api/predictions', {}, {}
    assert_equal 401, response.status
  end

end
