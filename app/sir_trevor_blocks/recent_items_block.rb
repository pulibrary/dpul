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
    builder = SearchBuilder.new(solr_helper).with(search_params)
    builder = builder.append :exclude_null_thumbnail

    repository.search(builder)
  end

  def search_params
    Blacklight::SearchState.new({ sort: "system_updated_at_dtsi DESC", rows: 10 }, blacklight_config).to_h
  end

  def repository
    blacklight_config.repository_class.new(blacklight_config)
  end
end
