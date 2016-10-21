module IndexHelper
  def render_index_document(document)
    field = index_presenter(document).label(document_show_link_field(document))
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
end
