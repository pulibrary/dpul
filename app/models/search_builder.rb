# frozen_string_literal: true

# Class for extending the default Blacklight builder for Solr queries
# @see https://github.com/projectblacklight/blacklight/wiki/Extending-or-Modifying-Blacklight-Search-Behavior
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Spotlight::SearchBuilder

  # Names for methods invoked when the Solr query is being built
  self.default_processor_chain += %i(hide_parented_resources join_from_parent)

  # Modifies the filter query in the Solr parameters to hide collections from being returned for all items in search results
  # @see https://lucene.apache.org/solr/guide/6_6/common-query-parameters.html#CommonQueryParameters-Thefq_FilterQuery_Parameter
  # @param solr_params [Blacklight::Solr::Request] the Solr query parameters being modified
  def hide_parented_resources(solr_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "!#{Spotlight::Engine.config.iiif_collection_id_field}:['' TO *]"
  end

  # Modifies the Solr query in order to retrieve child resources for all collections within search results
  # @param solr_params [Blacklight::Solr::Request] the Solr query parameters being modified
  def join_from_parent(solr_params)
    parent_query = solr_params[:q]
    solr_params[:defType] = "lucene"
    solr_params[:q] = JoinChildrenQuery.new(parent_query).to_s
  end

  def exclude_null_thumbnail(solr_params)
    solr_params[:fq] << "thumbnail_ssim:*"
  end
end
