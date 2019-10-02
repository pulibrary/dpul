# frozen_string_literal: true

class RecentItemsBlock < SirTrevorRails::Blocks::SolrDocumentsBlock
  def documents
    search_results.last
  end

  def search_results
    @search_results ||= solr_helper.search_results(user_query)
  end

  def user_query
    Blacklight::SearchState.new({ sort: "timestamp DESC", rows: 9 }, blacklight_config).to_h
  end
end
