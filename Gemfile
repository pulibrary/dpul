# frozen_string_literal: true

source 'https://gem.coop'

gem 'graphql-client'
gem 'health-monitor-rails', '~> 12.9'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'rack', '>= 2.0.6'
gem 'rails', '~> 7.2.0'
gem 'sassc-rails'
gem 'turbolinks'
gem 'uglifier', '4.1.0'

group :development, :test do
  gem 'bcrypt_pbkdf'
  gem 'byebug'
  # see comment in spec/requests/pages_spec
  gem 'cancancan'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rails-console'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'ed25519'
  gem 'factory_bot_rails', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'simplecov', require: false
  gem 'sshkit', '~> 1.18'
  gem 'webmock', require: false
end

group :test do
  gem "axe-core-rspec"
  gem "selenium-webdriver"
  gem "timecop"
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

gem 'acts-as-taggable-on'
gem 'bixby', '~> 5.0'
gem 'blacklight', '~> 7.18'
gem 'blacklight-gallery', '~> 4.5.0'
gem 'blacklight-oembed'
gem 'blacklight-spotlight', '~> 4.6.0'
gem 'bootstrap', '~> 4.6'
gem 'bootstrap_form', '~> 4.0'
# pinning connection_pool due to https://github.com/rails/rails/pull/56292
gem "connection_pool", "< 3"
gem 'ddtrace', require: "ddtrace/auto_instrument"
gem 'devise', '~> 4.9.0'
gem 'devise-guests', '~> 0.8'
gem 'devise_invitable'
gem 'faraday', '>= 1'
gem 'faraday-follow_redirects'
gem 'google-cloud-storage', group: :staging
gem 'iiif-presentation'
gem 'iso-639'
gem 'lograge'
gem 'logstash-event'
gem "net-smtp", require: false
gem 'omniauth', "> 1.0.0"
gem 'omniauth-cas'
gem 'omniauth-rails_csrf_protection'
# openseadragon is not compatible with sprockets starting at 1.0
gem 'openseadragon', '< 1.0.0'
gem 'open_uri_redirections'
gem 'rbtree', '>= 0.4.6'
gem 'redcarpet', '~> 3.5.1'
gem 'redis-namespace'
# Upgrading past redis 3.3.5 currently breaks deploy. Test any upgrades here carefully.
gem 'redis', '~> 4.5'
gem 'riiif'
gem 'rsolr', '~> 2.0'
# Required by blacklight-oembed
gem 'ruby2_keywords'
gem 'sidekiq', '~> 7.1.3'
gem 'sitemap_generator'
gem 'sneakers'
gem 'sprockets', '~> 3.7'
gem 'sprockets-es6'
gem 'string_rtl'
gem 'vite_rails'

gem 'dalli'
gem 'honeybadger'
gem 'nokogiri', '~> 1.18.9'
gem 'ruby-prof', require: false
gem 'rubyzip', '>= 1.2.2'

# Required for deployment under ruby 3.1
gem "net-imap", require: false
gem "net-pop", require: false
