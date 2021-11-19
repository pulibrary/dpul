# frozen_string_literal: true

source 'https://rubygems.org'

gem 'graphql-client'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'rack', '>= 2.0.6'
# Locking rails at 5.2.4.5 until we can handle this upgrade: https://github.com/rails/rails/releases/tag/v5.2.4.6
# The problem is CVE-2021-22885 and we should fix it upsteam.
gem 'rails', '5.2.4.5'
gem 'sass-rails', '~> 5.0'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'byebug'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rails-console'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'factory_bot_rails', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem "selenium-webdriver"
  gem 'simplecov', require: false
  gem 'sqlite3'
  gem 'sshkit', '~> 1.18'
  gem 'webmock', require: false
end

group :test do
  gem "axe-core-rspec"
  gem 'webdrivers', '~> 3.0'
end

group :development do
  gem 'puma'
  gem 'web-console', '~> 2.0'
end

group :production, :test do
  gem 'pg', '~> 0.20'
end

gem 'almond-rails', '~> 0.1'
gem 'bixby', '2.0.0'
gem 'blacklight', '~> 7.18'
gem 'blacklight-gallery'
gem 'blacklight-oembed'
gem 'blacklight-spotlight', '3.0.3'
gem 'bootstrap', '~> 4.0'
gem 'ddtrace'
gem 'devise', '~> 4.7.1'
gem 'devise-guests', '~> 0.3'
gem 'devise_invitable'
gem 'faraday', '< 1'
gem 'google-cloud-storage', group: :staging
gem 'iiif-presentation'
gem 'iso-639'
gem 'lograge'
gem 'logstash-event'
gem 'omniauth', '~> 1.8.1'
gem 'omniauth-cas'
gem 'open_uri_redirections'
gem 'redis-namespace'
# Upgrading past redis 3.3.5 currently breaks deploy. Test any upgrades here carefully.
gem 'redis', '3.3.5'
gem 'riiif'
gem 'rsolr', '~> 1.0.6'
# Required by blacklight-oembed
gem 'ruby2_keywords'
gem 'sidekiq', '< 6'
gem 'sitemap_generator'
gem 'sneakers'
gem 'sprockets', '~> 3.7'
gem 'sprockets-es6'
gem 'sprockets-rails'
gem 'string_rtl'
gem 'webpacker', '>= 4.0.x'

gem 'dalli'
gem 'honeybadger'
gem 'nokogiri', '~> 1.12.5'
gem 'ruby-prof', require: false
gem 'rubyzip', '>= 1.2.2'
