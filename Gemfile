# frozen_string_literal: true

source 'https://rubygems.org'

gem 'graphql-client'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'rack', '>= 2.0.6'
gem 'rails', '~> 6.1.6'
gem 'sass-rails', '~> 5.0'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'byebug'
  # see comment in spec/requests/pages_spec
  gem 'cancancan'
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
  gem 'web-console', '~> 4.0'
end

group :production, :test do
  gem 'pg'
end

source "https://gems.contribsys.com/" do
  gem "sidekiq-pro"
end

gem 'bixby', '2.0.0'
gem 'blacklight', '~> 7.18', '< 7.25'
gem 'blacklight-gallery'
gem 'blacklight-oembed'
gem 'blacklight-spotlight', '~> 3.0'
gem 'bootstrap', '~> 4.0'
gem 'bundler', '2.3.18'
gem 'ddtrace', require: "ddtrace/auto_instrument"
gem 'devise', '~> 4.7.1'
gem 'devise-guests', '~> 0.8'
gem 'devise_invitable'
gem 'faraday', '< 1'
gem 'google-cloud-storage', group: :staging
gem 'iiif-presentation'
gem 'iso-639'
gem 'lograge'
gem 'logstash-event'
gem 'omniauth', '~> 1.8.1'
gem 'omniauth-cas'
gem 'omniauth-rails_csrf_protection'
gem 'open_uri_redirections'
gem 'redcarpet', '~> 3.5.1'
gem 'redis-namespace'
# Upgrading past redis 3.3.5 currently breaks deploy. Test any upgrades here carefully.
gem 'redis', '~> 4.5'
gem 'riiif'
gem 'rsolr', '~> 2.0'
# Required by blacklight-oembed
gem 'ruby2_keywords'
gem 'sidekiq', '~> 5.2.10', '< 6'
gem 'sir_trevor_rails'
gem 'sitemap_generator'
gem 'sneakers'
gem 'sprockets', '~> 3.7'
gem 'sprockets-es6'
gem 'string_rtl'
gem 'vite_rails'

gem 'dalli'
gem 'honeybadger'
gem 'nokogiri', '~> 1.13.2'
gem 'ruby-prof', require: false
gem 'rubyzip', '>= 1.2.2'
