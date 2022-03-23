# frozen_string_literal: true

FactoryBot.define do
  factory :feature_page, class: 'Spotlight::FeaturePage' do
    exhibit
    sequence(:title) { |n| "FeaturePage#{n}" }
    published { true }
    content { '[]' }
  end
end
