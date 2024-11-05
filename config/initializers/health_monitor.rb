# frozen_string_literal: true

Rails.application.config.after_initialize do
  # Adds a patch a check is always critical if it's filtered for, otherwise fall
  # back to configured value.
  class HealthMonitor::Providers::Base
    def critical
      return true if request && request.parameters["providers"].present?
      configuration.critical
    end
  end

  HealthMonitor.configure do |config|
    config.cache
    config.add_custom_provider(CheckOverrides::Redis).configure do |provider_config|
      provider_config.critical = false
    end
    config.add_custom_provider(SolrStatus)
    config.add_custom_provider(SmtpStatus).configure do |provider_config|
      provider_config.critical = false
    end

    # Make this health check available at /health
    config.path = :health

    config.error_callback = proc do |e|
      Rails.logger.error "Health check failed with: #{e.message}"
    end
  end
end
