require 'ffaker'

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
    login { FFaker::InternetSE.login_user_name + Random.rand(100_000).to_s }
    password { 'password' }
    password_confirmation { 'password' }
    api_token { 'api_token' }
    timezone { 'Melbourne' }
  end

  factory :deadline_notification do
    association(:user)
    association(:prediction)
  end

  factory :response_notification do
    association(:user)
    association(:prediction)
  end

  factory :credence_game do
    association(:user)
    score { 0 }
    num_answered { 0 }
  end

  factory :credence_game_response do
    association(:credence_game)
    association(:credence_question)
    correct_index { 0 }
    asked_at { Time.zone.now }
    given_answer { nil }
    answer_credence { nil }
    answered_at { Time.zone.now }

    transient do
      first_answer { nil }
      second_answer { nil }
    end

    after(:build) do |response, evaluator|
      question = response.credence_question
      response.first_answer = evaluator.first_answer ||
                              FactoryGirl.create(:credence_answer, credence_question: question)
      response.second_answer = evaluator.second_answer ||
                               FactoryGirl.create(:credence_answer, credence_question: question)
    end

    trait :answered do
      given_answer { 0 }
      answer_credence { 60 }
    end
  end

  factory :credence_question do
    enabled { true }
    text_id { FFaker::Lorem.words(3) }
    text { 'Which thing comes sooner?' }
    prefix { 'The ' }
    suffix { ' thing' }
    weight { 1 }

    trait :with_answer do
      after(:build) do |question, _|
        FactoryGirl.build(:credence_answer, credence_question: question)
      end
    end
  end

  factory :credence_answer do
    association(:credence_question)
    text { 'An answer' }
    value { 'An answer' }
    rank { Random.rand(1..100) }
  end
end
