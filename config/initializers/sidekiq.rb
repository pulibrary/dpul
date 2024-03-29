# frozen_string_literal: true

require_relative "redis_config"

Sidekiq::Client.reliable_push! unless Rails.env.test?

Sidekiq.configure_server do |config|
  config.redis = { url: RedisConfig.url }
  config.super_fetch!
  config.reliable_scheduler!
end

Sidekiq.configure_client do |config|
  config.redis = { url: RedisConfig.url }
end
