FactoryGirl.define do
  factory :prediction do
    association(:creator, factory: :user)
    description { 'The world will end tomorrow!' }
    deadline { 1.day.ago }
    initial_confidence { '100' }
  end

  factory :response do
    association(:prediction)
    association(:user)
    confidence { 60 }
    comment { 'Yehar.' }
  end

  factory :judgement do
    association(:prediction)
    association(:user)
  end

  factory :user do
    email { FFaker::Internet.email }
    login { FFaker::InternetSE.login_user_name }
    password { 'password' }
    password_confirmation { 'password' }
    api_token { 'api_token' }
  end

  factory :deadline_notification do
    association(:user)
    association(:prediction)
  end

  factory :response_notification do
    association(:user)
    association(:prediction)
  end
end
