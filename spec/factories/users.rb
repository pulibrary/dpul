# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    transient do
      exhibit { FactoryBot.create(:exhibit) }
    end
    sequence(:email) { |n| "user#{n}@princeton.edu" }
    sequence(:username) { |n| "user#{n}" }
    uid do |user|
      user.username
    end
    provider { "cas" }

    factory :site_admin do
      after(:create) do |user, _evaluator|
        user.roles.create role: 'admin', resource: Spotlight::Site.instance
      end
    end

    factory :exhibit_admin do
      after(:create) do |user, evaluator|
        user.roles.create role: 'admin', resource: evaluator.exhibit
      end
    end
    factory :exhibit_curator do
      after(:create) do |user, evaluator|
        user.roles.create role: 'curator', resource: evaluator.exhibit
      end
    end

    factory :exhibit_visitor do
    end
  end
end
