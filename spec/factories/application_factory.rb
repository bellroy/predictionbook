FactoryGirl.define do

  factory :user, :aliases => [:creator] do
    login "zippy"
    password "123456"
    password_confirmation "123456"
  end

  factory :user_with_email, class: User do
    login "zippy"
    email "zippy@trikeapps.com"
    password "123456"
    password_confirmation "123456"
  end

  factory :prediction do
    creator
    description 'The world will end tomorrow!'
    deadline 1.day.ago
    initial_confidence '100'
  end

  factory :deadline_notification do
    user
    prediction { build(:prediction, :creator => user) }
  end

  factory :response_notification do
    user
    prediction
  end

end
