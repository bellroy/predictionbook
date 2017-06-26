require 'ffaker'

FactoryGirl.define do
  factory :prediction do
    association(:creator, factory: :user)
    prediction_group { nil }
    description { FFaker::Lorem.sentence }
    deadline { 1.day.ago }
    initial_confidence { '100' }

    trait :visible_to_everyone do
      visibility { Visibility::VALUES[:visible_to_everyone] }
      group_id { nil }
    end

    trait :visible_to_creator do
      visibility { Visibility::VALUES[:visible_to_creator] }
      group_id { nil }
    end

    trait :visible_to_group do
      visibility { Visibility::VALUES[:visible_to_group] }
    end
  end

  factory :prediction_group do
    description { FFaker::Lorem.sentence }

    transient do
      predictions { 0 }
      visibility { :visible_to_everyone }
      group_id { nil }
      creator { FactoryGirl.build(:user) }
    end

    after(:build) do |prediction_group, evaluator|
      prediction_group.predictions = FactoryGirl.build_list(:prediction, evaluator.predictions,
                                                            prediction_group: prediction_group,
                                                            visibility: evaluator.visibility,
                                                            group_id: evaluator.group_id,
                                                            creator: evaluator.creator)
    end
  end

  factory :response do
    association(:prediction)
    association(:user)
    confidence { 60 }
    comment { FFaker::Lorem.sentence }
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
    confirmed_at { 1.day.ago }
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
    text { FFaker::Lorem.sentence + '?' }
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
    text { FFaker::Lorem.sentence }
    sequence(:value)
    sequence(:rank)
  end

  factory :group do
    name { FFaker::Name.name }
  end

  factory :group_member do
    association(:group)
    association(:user)
    role { GroupMember::ROLES[:contributor] }

    trait :invitee do
      role { GroupMember::ROLES[:invitee] }
    end

    trait :contributor do
      role { GroupMember::ROLES[:contributor] }
    end

    trait :admin do
      role { GroupMember::ROLES[:admin] }
    end
  end
end
