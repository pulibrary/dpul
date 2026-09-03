# frozen_string_literal: true
Datadog.configure do |c|
  c.tracing.enabled = false unless Rails.env.production?
  # the tracing info injected into logs is messing with log parsing in signoz
  c.tracing.log_injection = false
  c.env = "production"
  c.service = "dpul"
end
