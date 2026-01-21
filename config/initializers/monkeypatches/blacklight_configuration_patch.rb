# frozen_string_literal: true

Rails.application.config.to_prepare do
  # Add the full image url to the autocomplete response
  module BlacklightConfigurationPatch
    def default_autocomplete_field_list(config)
      [
        super,
        Spotlight::Engine.config.full_image_field
      ].flatten.join(" ")
    end
  end

  Spotlight::BlacklightConfiguration.prepend(BlacklightConfigurationPatch)
end
