module IndexHelper
  def render_index_document(document)
    field = field_from document: document
    span = []
    if !field.is_a?(Array)
      span << content_tag(:span, style: 'display: block;', dir: field.dir) do
        link_to(field, url_for_document(document), document_link_params(document, {}))
      end
    else
      field.each do |value|
        span << content_tag(:span, style: 'display: block;', dir: value.dir) do
          link_to(value, url_for_document(document), document_link_params(document, {}))
        end
      end
    end
    safe_join span
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
