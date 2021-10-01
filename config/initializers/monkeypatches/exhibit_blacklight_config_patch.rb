# frozen_string_literal: true

Rails.application.config.to_prepare do
  module NoExhibitConfigPatch
    def blacklight_config
      if params[:exhibit_id] && current_exhibit.nil?
        @blacklight_config ||= self.class.blacklight_config.deep_copy
      else
        exhibit_specific_blacklight_config
      end
    end
  end

  # Non-existent pages don't have an exhibit, but get routed through the
  # Spotlight::HomePages controller. The search bar there requires a
  # blacklight_config. Normally the page should grab it from the exhibit, but
  # there's no exhibit, so provide the class' config, which is Blacklight's
  # default behavior.
  # TODO: Remove this if/when Spotlight gets built-in search-across
  # functionality, and thus a search bar everywhere.
  Spotlight::HomePagesController.prepend(NoExhibitConfigPatch)
end
