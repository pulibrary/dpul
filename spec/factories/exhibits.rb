# frozen_string_literal: true

FactoryBot.define do
  factory :exhibit, class: Spotlight::Exhibit do
    sequence(:title) { |n| "Exhibit Title #{n}" }
    sequence(:slug) { |n| "slug-#{n}" }
    published { true }
  end
end
