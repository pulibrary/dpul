# frozen_string_literal: true

# SirTrevor uses autocomplete to populate boxes and item metadata. The title
# with <li> in it breaks all the javascript - use the displays without the
# lists to fix that bug.
Rails.application.config.to_prepare do
  module AutocompletePatch
    def autocomplete_json_response_for_document(doc)
      super.merge(
        title: CGI.unescapeHTML(view_context.document_presenter(doc).html_title.to_str)
      )
    end
  end

  Spotlight::Base.prepend(AutocompletePatch)
end
