Rails.application.config.to_prepare do
  module SpotlightBreadcrumbPatch
    def add_document_breadcrumbs(document)
      if current_browse_category
        add_breadcrumb current_browse_category.exhibit.main_navigations.browse.label_or_default, exhibit_browse_index_path(current_browse_category.exhibit)
        add_breadcrumb current_browse_category.title, exhibit_browse_path(current_browse_category.exhibit, current_browse_category)
      elsif current_page_context && current_page_context.title.present? && !current_page_context.is_a?(Spotlight::HomePage)
        add_breadcrumb current_page_context.title, [current_page_context.exhibit, current_page_context]
      elsif current_search_session
        add_breadcrumb t(:'spotlight.catalog.breadcrumb.index'), search_action_url(current_search_session.query_params)
      end

      add_breadcrumb RTLShowPresenter.new(document, self).html_title, polymorphic_path([current_exhibit, document])
    end
  end

  # Overrides https://github.com/projectblacklight/spotlight/blob/v1.5.1/app/controllers/spotlight/catalog_controller.rb#L219
  # to use the show presenter for the last breadcrumb, rather than just pulling from the Solr document directly. Allows for our title override logic.
  Spotlight::CatalogController.prepend(SpotlightBreadcrumbPatch)
end
