module IndexHelper
  # generally spotlight asks the controller for the exhibit context you're in
  # but in bookmarks the exhibit context will vary between documents
  # so we have to specify that we want it
  def render_index_document(document, exhibit_context: false)
    field = field_from document: document
    spans = Array.wrap(field).map do |value|
      content_tag(:span, style: 'display: block;', dir: value.dir) do
        if exhibit_context
          contextual_label_link(value, document)
        else
          label_link(value, document)
        end
      end
    end
    safe_join spans
  end

  def label_link(value, document)
    link_to(value, url_for_document(document), document_link_params(document, {}))
  end

  def contextual_label_link(value, document)
    resource_id = document["spotlight_resource_id_ssim"].first.split("/").last
    exhibit = Spotlight::Resource.find(resource_id).exhibit
    link_to(value, contextual_url_for_document(document, exhibit), document_link_params(document, {}))
  end

  ##
  # The companion method `url_for_document` is defined in spotlight's
  # application helper
  def contextual_url_for_document(document, exhibit)
    return nil if document.nil?

    [spotlight, exhibit, document]
  end

  # Ensures that only a single string is passed from the IndexPresenter
  # @param current_presenter [Class]
  # @param show_link_field [Symbol]
  # @return [String]
  def index_masonry_document_label(document)
    field = field_from document: document
    Array.wrap(field).first
  end

  private

    def field_from(document:)
      index_presenter(document).label(document_show_link_field(document))
    end
end
