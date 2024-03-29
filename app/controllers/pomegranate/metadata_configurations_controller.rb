# frozen_string_literal: true

module Pomegranate
  class MetadataConfigurationsController < Spotlight::MetadataConfigurationsController
    delegate :_routes, to: :spotlight

    private

      def exhibit_configuration_index_params
        views = @blacklight_configuration.default_blacklight_config.view.keys | [:show]

        @blacklight_configuration.blacklight_config.index_fields.keys.index_with do |_element|
          (%i[enabled label weight text_area link_to_facet] | views)
        end
      end
  end
end
