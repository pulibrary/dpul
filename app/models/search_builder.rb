class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Spotlight::AccessControlsEnforcementSearchBuilder

  self.default_processor_chain += [:hide_parented_resources, :join_from_parent]

  def hide_parented_resources(solr_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "!#{Spotlight::Resources::Iiif::Engine.config.collection_id_field}:['' TO *]"
  end

  def join_from_parent(solr_params)
    solr_params[:q] = JoinChildrenQuery.new(solr_params[:q]).to_s
  end
end
