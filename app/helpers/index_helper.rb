# frozen_string_literal: true

module IndexHelper
  # generally spotlight asks the controller for the exhibit context you're in
  # but in bookmarks the exhibit context will vary between documents
  # so we have to retrieve it
  def render_index_document_title_heading(document, counter: nil, exhibit_context: false)
    field = field_from document: document
    title_links = Array.wrap(field).map.with_index do |value, i|
      content_tag(:span) do
        safe_join [counter_string(counter, i), title_link(value, document, exhibit_context)]
      end
    end
    safe_join title_links
  end

  private

    def field_from(document:)
      document_presenter(document).heading
    end

    # generate a counter prefix for the first title
    def counter_string(counter, title_index)
      return "" unless counter
      return "" unless title_index.zero?

      counter = document_counter_with_offset(counter)
      content_tag(
        :span,
        t("blacklight.search.documents.counter", counter:),
        class: ["document-counter"]
      )
    end

    # generate a title link with or without exhibit context
    def title_link(value, document, exhibit_context)
      content_tag(:span, dir: value.dir) do
        if exhibit_context
          contextual_label_link(value, document)
        else
          label_link(value, document)
        end
      end
    end

    def label_link(value, document)
      link_to(value, url_for_document(document), document_link_params(document, {}))
    end

    def contextual_label_link(value, document)
      resource_id = document["spotlight_resource_id_ssim"].first.split("/").last
      exhibit = Spotlight::Resource.find(resource_id).exhibit
      link_to(value, contextual_url_for_document(document, exhibit), document_link_params(document, {}))
    end

    # The companion method `url_for_document` is defined in spotlight's
    # application helper
    def contextual_url_for_document(document, exhibit)
      return nil if document.nil?

      if exhibit
        [spotlight, exhibit, document]
      else
        [main_app, document]
      end
    end
end
