# frozen_string_literal: true

class RTLShowPresenter < ::Blacklight::ShowPresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Context

  def field_value_separator
    tag('br')
  end

  def header
    fields = Array.wrap(title_field)
    f = fields.detect { |field| @document.has? field }
    f ||= @configuration.document_model.unique_key
    @document[f].to_sentence(field_config(f).separator_options)
    field_value(field_config(f), value: @document[f].map(&:html_safe))
  end

  def heading
    fields = Array.wrap(title_field)
    f = fields.detect { |field| document.has? field }
    f ||= configuration.document_model.unique_key
    field_value(field_config(f), value: document[f].map(&:html_safe))
  end

  # Automatically display the override title if it's present.
  def title_field
    if @document.has?(override_title_field) && Array.wrap(@document[override_title_field]).first.present?
      override_title_field
    else
      view_config.title_field
    end
  end

  def exhibit_prefix
    return nil if configuration.facet_fields["exhibit_tags"].blank?

    @exhibit_prefix ||= configuration.facet_fields["exhibit_tags"].field.gsub("tags_ssim", "")
  end

  def override_title_field
    :"#{exhibit_prefix}override-title_ssim"
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
