# frozen_string_literal: true
Datadog.configure do |c|
  c.tracing.enabled = false unless Rails.env.production?
  c.env = 'production'
  c.service = 'dpul'
end
