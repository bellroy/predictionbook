# frozen_string_literal: true

require 'ffaker'

FactoryBot.define do
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
      creator { FactoryBot.build(:user) }
    end

    after(:build) do |prediction_group, evaluator|
      prediction_group.predictions = FactoryBot.build_list(:prediction, evaluator.predictions,
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
    id { Random.rand(100_000) }

    trait :pseudonymous do
      login { User::PSEUDONYMOUS_LOGIN }
    end
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
