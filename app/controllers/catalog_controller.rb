##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog
  self.search_params_logic += [:hide_parented_resources, :join_from_parent]

  configure_blacklight do |config|
    config.show.oembed_field = :oembed_url_ssm
    config.show.partials.insert(1, :oembed)
    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]

    config.show.tile_source_field = :tile_source_ssim
    config.show.partials.insert(1, :universal_viewer)

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      fl: '*',
      group: true,
      'group.main': true,
      'group.limit': 1,
      'group.field': Spotlight::Resources::Iiif::Engine.config.iiif_manifest_field,
      'group.facet': true
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    # solr field configuration for search results/index views
    config.index.title_field = 'full_title_ssim'
    config.add_show_field 'creator_ssim', label: 'Creator'

    config.add_search_field 'all_fields', label: 'Everything'

    config.add_sort_field 'relevance', sort: 'score desc', label: 'Relevance'

    config.add_facet_field 'spotlight_resource_type_ssim'
    config.index.thumbnail_field = 'thumbnail_ssim'

    config.add_facet_fields_to_solr_request!
    config.add_field_configuration_to_solr_request!
    config.document_presenter_class = RTLPresenter
    config.response_model = AdjustedGroupedResponse
  end
end
