class RTLShowPresenter < ::Blacklight::ShowPresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Context

  def field_value_separator
    tag('br')
  end

  ##
  # Render the show field value for a document
  #
  #   Allow an extention point where information in the document
  #   may drive the value of the field
  #   @param [String] field
  #   @param [Hash] options
  #   @options opts [String] :value
  def field_value(field, options = {})
    tags = super.split(field_value_separator).collect do |value|
      value = collection_value(value) if field.to_s.include?("readonly_collections_ssim")
      content_tag(:li, value.html_safe, dir: value.dir)
    end

    content_tag(:ul) do
      safe_join tags
    end
  end

  def collection_value(value)
    collection = Spotlight::Exhibit.where(title: value).first
    return value unless collection
    unless view_context.respond_to?(:exhibit_path)
      Rails.logger.error "Failed to render the link to the collection #{value} for #{collection.id}"
      return value
    end
    link_to collection.title, view_context.exhibit_path(collection)
  end

  def header
    fields = Array.wrap(title_field)
    f = fields.detect { |field| @document.has? field }
    f ||= @configuration.document_model.unique_key
    @document[f].to_sentence(field_config(f).separator_options)
    field_value(f, value: @document[f].map(&:html_safe))
  end

  def heading
    fields = Array.wrap(title_field)
    f = fields.detect { |field| document.has? field }
    f ||= configuration.document_model.unique_key
    field_values(field_config(f), value: document[f].map(&:html_safe))
  end

  # Automatically display the override title if it's present.
  def title_field
    if @document.has?(override_title_field) && @document[override_title_field].present?
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
    super.split("<br />").map(&:html_safe).join(", ")
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
