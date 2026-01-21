# frozen_string_literal: true

Rails.application.config.to_prepare do
  require "spotlight/resources/iiif_service"

  module Spotlight
    module Resources
      class IiifService
        # Overridden to set a larger timeout value.
        # Some of our manifests take a long time time to load.
        def self.http_client
          Faraday.new(request: { timeout: 60 }) do |b|
            b.use Faraday::FollowRedirects::Middleware
            b.adapter Faraday.default_adapter
          end
        end
      end
    end
  end
end
