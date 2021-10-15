# frozen_string_literal: true

class RecentItemsBlock < SirTrevorRails::Blocks::SolrDocumentsBlock
  delegate :blacklight_config, to: :solr_helper

  def documents
    search_results
  end

  def search_results
    @search_results ||= search_response.documents
  end

  def search_response
    repository.search(search_builder)
  end

  def search_service
    solr_helper.controller.send(:search_service)
  end

  def search_builder
    builder = search_service.search_builder.with(search_params)
    builder.append :exclude_null_thumbnail
  end

  def search_params
    Blacklight::SearchState.new({ sort: "system_updated_at_dtsi DESC", rows: 10 }, blacklight_config).to_h
  end

  def repository
    blacklight_config.repository_class.new(blacklight_config)
  end
end
