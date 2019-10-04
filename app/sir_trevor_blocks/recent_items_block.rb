# frozen_string_literal: true

class RecentItemsBlock < SirTrevorRails::Blocks::SolrDocumentsBlock
  def documents
    search_results.last.select do |doc|
      doc.has? Spotlight::Engine.config.thumbnail_field
    end
  end

  def search_results
    @search_results ||= solr_helper.search_results(user_query)
  end

  def user_query
    Blacklight::SearchState.new({ sort: "system_updated_at_dtsi DESC", rows: 10 }, blacklight_config).to_h
  end
end
