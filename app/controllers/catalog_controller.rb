##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog
  before_action :search_across_settings

  def search_across_settings
    return if current_exhibit
    blacklight_config.add_index_field 'readonly_creator_ssim', label: 'Creator'

    blacklight_config.add_facet_field 'readonly_language_ssim', label: 'Language', limit: 10
    blacklight_config.add_facet_field 'readonly_subject_ssim', label: 'Subject', limit: 10
    unique_custom_fields.each do |field|
      blacklight_config.add_show_field field.field, label: field.configuration["label"]
    end
    blacklight_config.search_builder_class = SearchAcrossSearchBuilder
  end

  def unique_custom_fields
    Spotlight::CustomField.select(:field, :configuration).distinct.to_a.uniq(&:field)
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
      'group.field': Spotlight::Engine.config.iiif_manifest_field,
      'group.facet': true
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    # solr field configuration for search results/index views
    config.index.title_field = 'full_title_tesim'
    config.index.display_title_field = 'readonly_title_tesim'

    config.add_search_field 'all_fields', label: 'Everything'

    config.add_sort_field 'relevance', sort: 'score desc', label: 'Relevance'
    config.add_sort_field 'sort_title', sort: 'sort_title_ssi asc, sort_date_ssi desc', label: 'Title'
    config.add_sort_field 'sort_date', sort: 'sort_date_ssi desc, sort_title_ssi asc', label: 'Date'
    config.add_sort_field 'sort_author', sort: 'sort_author_ssi asc, sort_title_ssi asc', label: 'Author'

    config.add_facet_field 'spotlight_resource_type_ssim'
    config.add_facet_field 'readonly_collections_ssim', label: 'Collections', limit: 10
    config.add_index_field 'readonly_collections_ssim', label: 'Collections'
    config.index.thumbnail_field = 'thumbnail_ssim'

    config.add_facet_fields_to_solr_request!
    config.add_field_configuration_to_solr_request!
    config.response_model = AdjustedGroupedResponse
    config.show.document_presenter_class = RTLShowPresenter
    config.index.document_presenter_class = RTLIndexPresenter
    config.navbar.partials = []
    config.index.document_actions.delete(:bookmark)
    config.repository_class = ::FriendlyIdRepository
    config.http_method = :post
  end

  # Overrides the spotlight search_facet_url method to use
  # facet_catalog_url named route instead of catalog_facet_url.
  # https://github.com/projectblacklight/spotlight/blob/v1.4.1/app/controllers/concerns/spotlight/controller.rb#L63
  def search_facet_url(*args)
    return super if current_exhibit
    main_app.facet_catalog_url(*args)
  end

  # get a single document from the index
  # to add responses for formats other than html or json see _Blacklight::Document::Export_
  def show
    @response, @document = fetch params[:id], exhibit: @exhibit
    respond_to do |format|
      format.html { setup_next_and_previous_documents }
      format.json { render json: { response: { document: @document } } }
      additional_export_formats(@document, format)
    end
  end
end
