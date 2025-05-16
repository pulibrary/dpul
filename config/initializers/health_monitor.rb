# frozen_string_literal: true

Rails.application.config.after_initialize do
  # Adds a patch a monitor is always critical if it's filtered for, otherwise
  # fall back to configured value.
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
    config.solr.configure do |c|
      c.url = Blacklight.default_index.connection.uri.to_s
      c.collection = Blacklight.default_index.connection.uri.path.split("/").last
    end
    config.add_custom_provider(SmtpStatus).configure do |provider_config|
      provider_config.critical = false
    end
    config.file_absence.configure do |file_config|
      file_config.filename = "public/remove-from-nginx"
    end
    config.add_custom_provider(MountStatus)

    # Make this health monitor available at /health
    config.path = :health

    config.error_callback = proc do |e|
      Rails.logger.error "Health monitor failed with: #{e.message}" unless e.is_a?(HealthMonitor::Providers::FileAbsenceException)
    end
  end
end
