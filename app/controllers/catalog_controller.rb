##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog
  before_action :search_across_settings

  def search_across_settings
    return if current_exhibit
    blacklight_config.add_index_field 'readonly_subject_tesim', label: 'Subject'
    blacklight_config.add_index_field 'readonly_description_tesim', label: 'Description'

    blacklight_config.add_facet_field 'readonly_language_ssim', label: 'Language'
    blacklight_config.add_facet_field 'readonly_format_ssim', label: 'Format'
    unique_custom_fields.each do |field|
      blacklight_config.add_show_field field.field, label: field.configuration["label"]
    end
  end

  def unique_custom_fields
    Spotlight::CustomField.select(:field, :configuration).distinct
  end

  configure_blacklight do |config|
    config.show.oembed_field = :oembed_url_ssm
    config.show.partials.insert(1, :oembed)
    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]

    config.show.tile_source_field = :tile_source_ssim
    config.show.partials.insert(1, :universal_viewer)
    config.view.embed.partials = ['universal_viewer']

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
    config.index.display_title_field = 'readonly_title_tesim'

    config.add_search_field 'all_fields', label: 'Everything'

    config.add_sort_field 'relevance', sort: 'score desc', label: 'Relevance'

    config.add_facet_field 'spotlight_resource_type_ssim'
    config.index.thumbnail_field = 'thumbnail_ssim'

    config.add_facet_fields_to_solr_request!
    config.add_field_configuration_to_solr_request!
    config.response_model = AdjustedGroupedResponse
    config.show.document_presenter_class = RTLShowPresenter
    config.index.document_presenter_class = RTLIndexPresenter
    config.navbar.partials = []
    config.index.document_actions.delete(:bookmark)
  end
end
