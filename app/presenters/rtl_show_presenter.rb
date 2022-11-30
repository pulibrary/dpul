# frozen_string_literal: true

class RTLShowPresenter < ::Blacklight::ShowPresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Context

  def field_value_separator
    tag.br
  end

  def html_title
    super.split(/<\/li><li.*?>/).map(&:html_safe).join(", ").gsub(/<.*?>/, "")
  end

  def field_config(field)
    super.tap do |f|
      f.separator_options =
        {
          words_connector: field_value_separator,
          two_words_connector: field_value_separator,
          last_word_connector: field_value_separator
        }
    end
  end
end
