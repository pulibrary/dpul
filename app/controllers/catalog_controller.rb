# frozen_string_literal: true

##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog
  before_action :search_across_settings
  rescue_from Blacklight::Exceptions::RecordNotFound, with: :not_found

  def search_across_settings
    return if current_exhibit

    blacklight_config.add_index_field 'readonly_creator_ssim', label: 'Creator'

    blacklight_config.add_facet_field 'readonly_language_ssim', label: 'Language', limit: 10
    blacklight_config.add_facet_field 'readonly_subject_ssim', label: 'Subject', limit: 10
    [:embed, :gallery, :masonry, :slideshow].each do |view|
      blacklight_config.view.delete(view)
    end
    unique_custom_fields.each do |field|
      blacklight_config.add_show_field field.field, label: field.configuration["label"]
    end
    blacklight_config.search_builder_class = SearchAcrossSearchBuilder
  end

  def unique_custom_fields
    Spotlight::CustomField.select(:field, :configuration).distinct.to_a
                          .uniq(&:field).reject { |v| v.field == 'readonly_range-label_ssim' }
  end

  configure_blacklight do |config|
    config.raw_endpoint.enabled = true
    config.show.oembed_field = :oembed_url_ssm
    config.show.partials.insert(1, :oembed)
    # Default Configurations
    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    config.view.gallery!.document_component = Blacklight::Gallery::DocumentComponent
    # config.view.gallery.classes = 'row-cols-2 row-cols-md-3'
    config.view.masonry!.document_component = Blacklight::Gallery::DocumentComponent
    config.view.slideshow!.document_component = Blacklight::Gallery::SlideshowComponent
    config.view.gallery!(partials: [:index_header, :index])
    config.view.masonry!(partials: [:index])
    config.view.slideshow!(partials: [:index])

    config.show.tile_source_field = :tile_source_ssim
    config.index.tile_source_field = :tile_source_ssim
    config.show.partials.insert(1, :universal_viewer)
    config.view.embed(partials: ['universal_viewer'])

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    # Make browse results doc actions consistent with search result doc actions
    config.browse.document_actions = config.index.document_actions

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    # Group records by manifest in order to display a single result for a given
    # resource in 'search across'
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

    config.fetch_many_document_params = {
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

    config.add_search_field 'all_fields', label: 'Keyword'
    config.add_search_field 'title', label: 'Title'
    config.add_search_field 'publisher', label: 'Publisher'
    config.add_search_field 'subject', label: 'Subject'

    config.add_sort_field 'relevance', sort: 'score desc', label: 'Relevance'
    config.add_sort_field 'sort_title', sort: 'sort_title_ssi asc, sort_date_ssi desc', label: 'Title'
    config.add_sort_field 'sort_date_desc', sort: 'sort_date_ssi desc, sort_title_ssi asc', label: 'Date Descending'
    config.add_sort_field 'sort_date_asc', sort: 'sort_date_ssi asc, sort_title_ssi asc', label: 'Date Ascending'
    config.add_sort_field 'sort_author', sort: 'sort_author_ssi asc, sort_title_ssi asc', label: 'Author'

    config.add_facet_field 'spotlight_resource_type_ssim'
    config.add_facet_field 'readonly_collections_ssim', label: 'Collections', limit: 10
    config.add_index_field 'readonly_collections_ssim', label: 'Collections', helper_method: :collection_links
    config.index.thumbnail_method = :document_thumbnail

    # The embed view doesn't look good, so remove it.
    config.view.delete(:embed)

    config.add_facet_fields_to_solr_request!
    config.add_field_configuration_to_solr_request!
    config.response_model = AdjustedGroupedResponse
    config.show.document_presenter_class = RTLShowPresenter
    config.index.document_presenter_class = RTLIndexPresenter
    config.repository_class = ::FriendlyIdRepository
    config.http_method = :post
  end

  # Overrides the spotlight search_facet_url method to use
  # facet_catalog_path named route instead of catalog_facet_path.
  # https://github.com/projectblacklight/spotlight/blob/v3.0.3/app/controllers/concerns/spotlight/controller.rb#L78
  def search_facet_path(*args)
    return super if current_exhibit

    main_app.facet_catalog_path(*args)
  end

  # search results
  def index
    @masthead_title = "Search Results"
    super
  end

  # get a single document from the index
  # to add responses for formats other than html or json see _Blacklight::Document::Export_
  def show
    @response, @document = search_service.fetch params[:id], exhibit: @exhibit
    respond_to do |format|
      format.html { setup_next_and_previous_documents }
      format.json { render json: { response: { document: @document } } }
      additional_export_formats(@document, format)
    end
  end
end
