# frozen_string_literal: true

Rails.application.config.to_prepare do
  module ContextualEditPatch
    def edit
      @response, @document = search_service.fetch params[:id], exhibit: @exhibit
    end

    def update
      @response, @document = search_service.fetch params[:id], exhibit: @exhibit
      @document.update(current_exhibit, solr_document_params)
      @document.save

      try_solr_commit!

      redirect_to polymorphic_path([current_exhibit, @document])
    end
  end

  # Since we have documents that share a short-id (the end of the ARK), but have
  # different document IDs depending on which exhibit they're in, it's important
  # that when editing a SolrDocument we get the one from the current exhibit. If
  # we don't, then there's a good chance it's editing a document from another
  # exhibit.
  Spotlight::CatalogController.prepend(ContextualEditPatch)
end
