ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def valid_prediction_params
    { prediction: {
      deadline: Random.rand(100).days.from_now,
      initial_confidence: Random.rand(100),
      creator: User.first,
      description: "this event won't come true"
    }
    }
  end

  def invalid_prediction_params
    { prediction: {
      deadline: Random.rand(100).days.from_now,
      creator: User.first,
      description: "this event won't come true"
    }
    }
  end

  def valid_user_params
    { login: 'Test', password: 'blahblah', password_confirmation: 'blahblah' }
  end

  def valid_query_string
    "?username=#{valid_user_params[:login]}&password=#{valid_user_params[:password]}"
  end
end
