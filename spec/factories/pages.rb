FactoryBot.define do
  factory :about_page, class: 'Spotlight::AboutPage' do
    exhibit
    sequence(:title) { |n| "AboutPage#{n}" }
    published true
    content '[]'
  end
end
