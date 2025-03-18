# frozen_string_literal: true

Rails.application.config.after_initialize do
  Deprecation.default_deprecation_behavior = :silence if Rails.env.production?
end
